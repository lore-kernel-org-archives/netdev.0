From: Chetan Loke <chetanloke@gmail.com>
Subject: [RFC] Enhance dev_ioctl to return <hwaddr>:<if_name::if_index>
	mapping
Date: Fri, 16 Jul 2010 09:18:04 -0400
Message-ID: <AANLkTinxLy2noL0GcZyVtMsEndxseCr6kkxuvyBNIfHr@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: chetanloke@gmail.com, "Loke, Chetan" <chetan.loke@netscout.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:36623 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965485Ab0GPNSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 09:18:05 -0400
Received: by vws5 with SMTP id 5so2516124vws.19
        for <netdev@vger.kernel.org>; Fri, 16 Jul 2010 06:18:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello All,

I meant to 'CC' netdev earlier(http://lkml.org/lkml/2010/7/15/334).
Please 'CC' me.

LKML Post:
http://kerneltrap.org/mailarchive/linux-kernel/2010/7/12/4592938


This proposal will provide the ability to shoot an
(early?/prep-time?)'ioctl' via an 'ethX'
agnostic naming scheme.

Requirement:
R1)Ability to address NICs/interfaces using a mac-addr in ioctls. This
is required because we don't have a consistent naming scheme for
Ethernet devices.Asking customers and/or field-engineers to change
udev rules and
other config files is not feasible.

Existing pain-points:
P1) ioctl needs either i) if-name or ii) if-index before we can invoke
bind() etc.This works fine if you know your configuration and it is not going
to change.However,if we hot-add a NIC and if you have adapters from multiple
vendors(think:driver load order) then upon a reboot,the 'eth'
interfaces can be re-mapped.

Existing work-around(s):
W1) user-apps scan /sys/class/net/ethX/address nodes, grep the hw-addrs
till they find a hwaddr-match and then internally create a hwaddr-ethX
mapping table.
W2) change udev-70..persistent rules file and 'rename' the interfaces
according to your needs.
  W2.1) If renaming were to even succeed then none of the existing
drivers re-register their msix-vectors.
  NETDEV_RENAME(or _CHANGE ) handler in the driver does not tear down
the interrupts etc.Some of the sample msix-vectors are as follows : ethX-rx-0,
ethX-rx-1 ... ethX-rx-N
  So if the interface is renamed then how do we measure/correlate the
interrupt-count?

But there is no programmatic way of deriving the 'ethX' name. I got a
few offline replies to the above post, asking me to continue using W1)
from above.Sorry but that was an ugly hack. Also why not replace the
get-ioctls to a 'sys' read everywhere?? ;).

Solution/Proposal:
S1)   Introduce a new ioctl(SIOCGHWADDR_TO_IFNAMEINDEX_MAP[or pick your
name])
S1.1) Enhance dev_ioctl to handle this new case.
S1.2  Re-use for_each_netdev_rcu::is_etherdev_addr(this will iterate
through dev_addrs). By using the above for_each loop we don't need to
re-invent the
wheel.

Input(ifr->hw_addr) : output -> if_name and if_index if ifr->hw_addr is
found.

This way an app can first shoot down an ioctl(sock_fd,
SIOCGHWADDR_TO_IFNAMEINDEX_MAP,ifr), where ifr.ifr_hwaddr is populated
w/ the mac_addr whose mapping you would like.
Then once the if_name and if_index is known, using other ioctls is easy.


Please review the proposal and the sample code below. If this is not a
good approach and if there is a simple workaround then please let me
know.


Regards
Chetan Loke


----------------------------------------------------------

Sample code(PS- I used a quick and dirty driver to demonstrate the
concept rather than modifying the kernel)


Copyright NetScout Systems
Chetan Loke <loke.c@alumni.neu.edu>

struct foo {
      char name[IFNAMSIZ];
      int  index;
};

/* shamelessly copied from compare_etherdev */
/* eventually is_etherdev_equal will be called by dev_ioctl */
int ntct_is_etherdev_equal(u16 *a,u16 *b) {
      return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | (a[2] ^ b[2])) == 0;
}

/* eventually enhance dev_ioctl */
int _do_ioctl(unsigned long arg) {

      struct foo my_foo;
      struct net_device *dev;
      int ret=0;
      int found=0;
      int i=0;

      /* eventually sent via
ioctl(sock_fd)->SIOCG_HWADDR_TO_NAMEIDX_MAP and ifr->hw_addr */
      unsigned char mac_addr[]={0x00,0x50,0x56,0xBB,0x52,0xF7};

      /* eventually use rcu_read_lock(); */
      read_lock(&dev_base_lock);

      /* 2.6.31 doesn't have this defined. eventually use
for_each_netdev_rcu. */
      for_each_netdev(&init_net, dev) {
              dev_hold(dev);

              /* eventually use is_etherdev_addr(addr1,addr2) */
              ret = ntct_is_etherdev_equal((u16 *)dev->dev_addr,(u16*)mac_addr);
              if (ret) {
                      printk("<%s> Found
eth-if:%sifindex:%d\n",__func__,dev->name,dev->ifindex);
                      printk("Mac:");
                      for (i=0;i<ETH_ALEN;i++)
                              printk("%02x%c",(unsigned
char)dev->dev_addr[i],((i < 5)? ':':' '));
                      printk("\n");
                      strcpy(my_foo.name,dev->name);
                      my_foo.index=dev->ifindex;
                      dev_put(dev);
                      found=1;
                      break;
              }
              dev_put(dev);
      }

      /* eventually use rcu_read_unlock(); */
      read_unlock(&dev_base_lock);

      if (!found) {
              printk("<%s> hwaddr<->name mapping not found\n",__func__);
              return -EINVAL;
      }

      return copy_to_user((char *)arg,&my_foo,sizeof(struct foo)) ? -EFAULT : 0;
}
