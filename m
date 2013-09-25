From: Merlin Davis <me.the.wizard@gmail.com>
Subject: Re: Kernel Panic Sending Frames Using dev_queue_xmit()
Date: Wed, 25 Sep 2013 14:29:40 -0700
Message-ID: <CAFu7c2XDYR-SMiuqMxtqGhfM00nw8-h0Tr2uewN8+D1BptsayA@mail.gmail.com>
References: <CAFu7c2V+gubfzG4HdWtPWJ-w2x3J-RToUT2mdahcKSgn66fDzg@mail.gmail.com>
	<1380133174.2222.13.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f52.google.com ([209.85.212.52]:40770 "EHLO
	mail-vb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755690Ab3IYV3l convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 17:29:41 -0400
Received: by mail-vb0-f52.google.com with SMTP id f12so223437vbg.39
        for <netdev@vger.kernel.org>; Wed, 25 Sep 2013 14:29:40 -0700 (PDT)
In-Reply-To: <1380133174.2222.13.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> You are more likely to get help if you include the code in your email
> rather than linking to it.

Understood.  Thank you for the protocol tip.  Here is the code
(test_send.c) of the module causing the kernel panic when I send SKBs
through dev_queue_xmit().  Below it are my notes (NOTES.txt) on the
behavior, testing, etc.


test_send.c
=3D=3D=3D=3D=3D=3D=3D=3D

#include <linux/err.h>
#include <linux/if_ether.h>
#include <linux/kernel.h>
#include <linux/kthread.h>
#include <linux/module.h>
#include <linux/netdevice.h>
#include <linux/rcupdate.h>
#include <linux/sched.h>
#include <linux/skbuff.h>
#include <linux/string.h>

#include <net/net_namespace.h>


MODULE_LICENSE("GPL");
MODULE_AUTHOR("Merlin Davis <me.the.wizard@gmail.com>");

static char* iface =3D "eth0";
module_param(iface, charp, 0);
MODULE_PARM_DESC(iface, "Name of output interface");

static unsigned long n =3D 0;
module_param(n, ulong, 0);
MODULE_PARM_DESC(
   n, "Number of packets to send (zero for continuous)");


static const unsigned int MAX_PENDING =3D 10u;

static struct net_device* sendDev =3D NULL;
static struct task_struct* sendThread =3D NULL;
static unsigned long nSent =3D 0uL;
static atomic_t nPending;
static wait_queue_head_t sendWq;

// Real ICMP echo response frame captured from eth0
static char FRAME_DATA[] =3D
   {
      0x0a, 0x00, 0x27, 0x00, 0x00, 0x00, // dest MAC addr
      0x08, 0x00, 0x27, 0x98, 0xa0, 0xea, // src MAC addr
      0x08, 0x00,                         // IPv4

      0x45,                    // v4, header length 20
      0x00,                    // DCSP, ECN
      0x00, 0x54,              // total IPv4 length 84
      0xdc, 0x5a,              // ID
      0x00, 0x00,              // flags, fragment offset
      0x40,                    // TTL 64
      0x01,                    // protocol ICMP
      0xac, 0xf2,              // IPv4 header checksum
      0xc0, 0xa8, 0x38, 0x0a,  // src IP addr
      0xc0, 0xa8, 0x38, 0x01,  // dest IP addr

      0x00,                    // echo reply
      0x00,                    // code 0
      0xf8, 0x17,              // ICMP header checksum
      0x07, 0x80,              // echo ID
      0x00, 0x0a,              // echo sequence number

      // echo data
      0x94, 0x89, 0x16, 0x52, 0x00, 0x00, 0x00, 0x00,
      0x8d, 0xaf, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
      0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f,
      0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27,
      0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f,
      0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37
   };


static void testSend_exit(void);
static int testSendThreadfn(void* data);
static void testSend_skb_destruct(struct sk_buff* skb);


static int __init testSend_init(void)
{
   struct net* netNs =3D NULL;
   int err =3D 0;

   atomic_set(&nPending, 0);
   init_waitqueue_head(&sendWq);

   if (!iface)
   {
      printk(KERN_ERR
             "test_send: Non-null device name must be "
             "specified via iface=3D<name>\n");
      err =3D -EINVAL;
      goto err;
   }

   rcu_read_lock();
   for_each_net_rcu(netNs)
   {
      sendDev =3D dev_get_by_name(netNs, iface);
      if (sendDev)
      {
         break;
      }
   }
   netNs =3D NULL;
   rcu_read_unlock();

   if (!sendDev)
   {
      printk(KERN_ERR "Invalid device name '%s'\n", iface);
      err =3D -EINVAL;
      goto err;
   }

   sendThread =3D kthread_run(testSendThreadfn, 0, "test_send");
   if (IS_ERR(sendThread))
   {
      err =3D PTR_ERR(sendThread);
      sendThread =3D NULL;
      goto err;
   }
   // keep reference so we can kthread_stop() even after
   //    thread returns
   get_task_struct(sendThread);

   return 0;

err:
   testSend_exit();
   return err;
}
module_init(testSend_init);


static void testSend_exit(void)
{
   if (sendThread)
   {
      kthread_stop(sendThread);
      // cleanup extra reference kept for the kthread_stop()
      put_task_struct(sendThread);
      sendThread =3D NULL;
   }

   while (atomic_read(&nPending) > 0)
   {
      wait_event_interruptible(sendWq,
                               atomic_read(&nPending) <=3D 0);
   }

   if (sendDev)
   {
      dev_put(sendDev);
      sendDev =3D NULL;
   }
}
static void __exit _testSend_exit(void)
{
   testSend_exit();
   printk(KERN_INFO "test_send: Sent %lu frames\n", nSent);
}
module_exit(_testSend_exit);


static int testSendThreadfn(void* data)
{
   int reservedSpace =3D max((int)LL_RESERVED_SPACE(sendDev),
                           (int)sizeof(struct ethhdr));
   int buffLen =3D reservedSpace - sizeof(struct ethhdr) +
                 sizeof(FRAME_DATA) +
                 sendDev->needed_tailroom;

   while (!kthread_should_stop() && (n =3D=3D 0 || nSent < n))
   {
      struct sk_buff* skb =3D NULL;
      int err =3D 0;

      while (atomic_read(&nPending) >=3D MAX_PENDING)
      {
         wait_event_interruptible(
            sendWq, atomic_read(&nPending) < MAX_PENDING);
         if (kthread_should_stop())
         {
            goto out;
         }
      }

      skb =3D alloc_skb(buffLen, GFP_KERNEL);
      if (!skb)
      {
         printk(KERN_ERR "test_send: Couldn't allocate SKB\n");
         schedule();
         continue;
      }

      skb_reserve(skb, reservedSpace);
      skb_reset_network_header(skb);
      skb_put(skb, sizeof(FRAME_DATA) - sizeof(struct ethhdr));
      skb_push(skb, sizeof(struct ethhdr));
      skb_reset_mac_header(skb);
      skb_reset_mac_len(skb);
      err =3D skb_store_bits(skb,
                           0,
                           FRAME_DATA,
                           sizeof(FRAME_DATA));
      if (err)
      {
         printk(KERN_ERR
                "test_send: Error %d storing to SKB\n", err);
         schedule();
         continue;
      }

      skb->dev =3D sendDev;
      skb->protocol =3D htons(ETH_P_IP);
      skb->destructor =3D testSend_skb_destruct;
      skb_shinfo(skb)->destructor_arg =3D NULL;

      // NOTE: Without this, the destructor is called twice and
      //    there is an almost immediate kernel panic.  With it,
      //    a kernel panic still occurs but takes a while to
      //    manifest.
      skb_get(skb);

      atomic_inc(&nPending);
      err =3D net_xmit_eval(dev_queue_xmit(skb));
      if (err)
      {
         printk(KERN_ERR
                "test_send: Error %d sending frame\n", err);
         schedule();
         continue;
      }

      ++nSent;

      //printk(KERN_ERR "test_send: SENT SKB\n");
   }
out:

   return 0;
}

static void testSend_skb_destruct(struct sk_buff* skb)
{
   //printk(KERN_ERR "test_send: DESTRUCTING SKB\n");
   atomic_dec(&nPending);
   wake_up_all(&sendWq);
}


NOTES.txt
=3D=3D=3D=3D=3D=3D=3D=3D

* Running on a VirtualBox VM with 64-bit Ubuntu 12.10 and the
  3.5.0-40-generic kernel (and matching kernel headers for
  module compilation).  The VM has been allocated 4 CPU cores
  and 2GB of memory (it has no swap partition).  The module had
  been tested on a previous kernel version (also 3.5.0-x) and
  exhibited the same symptoms.  The network adapter set in
  VirtualBox is the default "Intel PRO/1000 MT Desktop
  (82540EM)", and uses the e1000 driver
  (drivers/net/ethernet/intel/e1000).  However, other adapters
  in VirtuaBox's list of choices that use different drivers have
  also been tested with the same results.

* I have also tested this code on bare metal with a network card
  using Intel's igb driver and on a VM with a compiled 2.6.39
  kernel using all default configuration parameters, with the
  same results.

* The idea of the module is to resend/replay frames previously
  captured on the same network interface.  The frames are
  byte-for-byte identical to one originally captured.  The
  captured frame was an ICMP echo reply captured during ping
  execution between the host machine and the VM, on the same
  interface being tested (eth0 set to static 192.168.56.10/24 on
  a VirtualBox host-only network); the packet was manually
  inspected to verify it is a valid Ethernet/IPv4/ICMP/echo
  reply message with correct checksums.  This small module is a
  stripped down test case created after running into the problem
  in a larger project (one which DOES send packets associated
  with a socket).

* The frames are sent without a socket, in a manner similar to
  the way they are created and sent for IPv4 ARP.  In fact, the
  frames are constructed and sent in a way that is almost
  identical to the way net/ipv4/arp.c does it.  The exception is
  that this module uses complete frame data including the
  Ethernet header, unlike ARP which adds the hardware header
  using dev_hard_header().  This module has been tested by
  changing the code to use dev_hard_header() in an attempt to
  diagnose the problem, but this does not change the behavior.

* A kernel panic occurs after sending one or more frames using
  this module.  The number of frames sent before the panic
  occurs seems to vary, but it is inevitable that one occurs.
  The panic does not always occur in the same place in kernel
  code, but usually happens somewhere in __kfree_skb()=97perhaps
  in skb_release_head_state() as "? skb_release_head_state+..."
  is the last line of the kernel stack trace.  Sometimes,
  though, it happens in the qdisk code for transmission or the
  e1000 driver itself instead.  It is ALMOST always a "BUG:
  unable to handle kernel NULL pointer dereference", but rarely
  I have seen a general protection fault instead.

* The first implementation sent SKBs endlessly and without
  pause.  This caused a panic much quicker.  The code was then
  changed to limit the number of outstanding SKBs pending in the
  transmit code, similar to the way a socket's limited amount of
  buffer space would (but done using a simple counter).  This
  results in the same sort of panic, but after a longer period
  of time since the sned rate is naturally lower.  Counting the
  number of outstanding SKBs also resulted in the discovery of
  an SKB reference counting problem.

* Calling dev_queue_xmit() with an SKB is supposed to turn
  ownership of the SKB over to the transmit code, according to
  the API documentation in net/core/dev.c.  This would seem to
  imply the reference count should be 1, and that reference is
  turned over to the callee.  However, when the reference count
  is only 1, the transmit code destructs each SKB twice, meaning
  somewhere it must be decrementing the reference count and
  assuming it is still positive, then later incrementing and
  decrementing it again.  This causes an immediate kernel panic
  in either the code to free the SKB or in a later memory
  allocation operation.

* When an SKB's reference count is incremented to 2 just before
  calling dev_queue_xmit(), the destructor seems to be called
  just once (this can be tested by uncommenting a couple of
  printk's in the code and loading the module with parameter
  "n=3Dx" to send x frames before terminating the send thread,
  then checking the messages using dmesg, grep, wc, etc.).  With
  this reference count fix the kernel panic still occurs, but
  only after the relatively long and varying period of execution
  mentioned above (generally after hundreds of thousands of
  frames).  On the VM I am testing on, the panic usually happens
  after somewhere between 15 seconds and 2 minutes.

* My best guess is that SOMETHING is overwriting memory with
  null bytes or random data or soemthing.  Is there something
  wrong with the way the SKBs are being allocated, prepared,
  turned over to the kernel for transmission, cleaned up, etc.?
  If so, how is it different from the ARP implementation in a
  way that causes a panic?  Or is this a defect in the kernel
  code itself, in which case how can Linux machines stay stable
  and running with significant uptimes?  Or is it just that this
  is a very infrequent race condition of some sort and ARP
  transmission is slow/infrequent enough that the mean time
  before failure is very, very long?

* I have attempted both kernel debugging and panic message
  capture, but despite following all the instructions I can find
  online for doing this with a VirtualBox VM, I cannot seem to
  get the debugger to resume execution properly when debugging,
  the emulated serial console to work, or a crash dump to appear
  in the VM after restart.  So I seem to be stuck with code
  inspection and good ol' printk-style debugging, unfortunately.
