From: Nj A <nj_a83@yahoo.fr>
Subject: Re : Bug in using inet_lookup ()
Date: Fri, 16 Nov 2007 09:47:08 +0000 (GMT)
Message-ID: <409407.88982.qm@web26101.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web26101.mail.ukl.yahoo.com ([217.146.182.142]:26480 "HELO
	web26101.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754924AbXKPJrL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2007 04:47:11 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
> Please show at least one bug trace when inet_lookup(&tcp_hashinfo, 0, 0, 0, 0,
> 0) fails :)
Trying this the system hangs :-( (setting panic* doesn't change more).
However, using (&tcp_hashinfo, ip_src, p_src, ip_dst, p_dst, 0) gives the following oops:
BUG: unable to handle kernel NULL pointer dereference at virtual address 0000xxxx
printing eip:
c02f19e1
*pde = 00000000
Oops: 0000 [#1]
CPU:    0
EIP:    0060:[<c02f19e1>]    Not tainted VLI
EFLAGS: 00010282   (2.6.18 #1)
EIP is at inet_lookup+0x300x500
eax: 9e3779b9   ebx: 00000004   ecx: 9e377a57   edx: f4046f84
esi: f46a6010   edi: 00000000   ebp: 0000009e   esp: f4046f38
ds: 007b   es: 007b   ss: 0068
Process knl-thread (pid: 3068, ti=f4046000 task=f46f0610 task.ti=f4046000)
Stack: 22921900 f6953840 f46a6010 f46a6000 f4046f84 00000004 f46a6010 f46a6000
f6953840 f8d3314a 00000004 b7f3a000 00000404 00000005 00000bfe 00000000
00000bfe 00000404 00000000 f4046fa8 f6953840 f4aa7880 f4aa7800 f4046fa8
Code: 00 00 00 8d bc 27 00 00 00 00 55 89 cd 57 0f b7 c9 56 81 e9 47 86 c8 61 53 83 ec 14 89 54 24 10 8b b8 54 02 00 00 b8 b9 79 37 9e <8b> 5f 10 29 d8 89 da 03 44 24 28 c1 ea 0d 29 c8 29 d9 31 d0 89
EIP: [<c02f19e1>] inet_lookup +0x300x500 SS:ESP 0068:f4046f38

> Yes, to show the code you are using.
Ok so basically I am receiving via Netlink a state telling me the ip_src, psrc, ip_dst, pdst.
The goal is to lookup the corresponding state. Going through the inet_lookup() function I see that's it is not amazing it returns the wrong thing.
/* Receive state via Netlink in payload */
...
if ((s_skb = alloc_skb (MAX_TCP_HEADER + 15, GFP_ATOMIC)) == NULL)
 {
   err = -ENOMEM;
 }
  dev = s_skb->dev;
  if (!dev)
   {
      goto pdev;
   }
sk =
     inet_lookup (&tcp_hashinfo, payload->src, payload->p_src, payload->dst, payload->p_dst, inet_iif (s_skb));
if (!sk)
     goto no_tcp_socket;
 if (sk->sk_state == TCP_TIME_WAIT)
     goto time_wait_socket;
 ...
      bh_lock_sock (sk);
 pdev:
      spin_lock (&tmp_lock);
      new_dev = list_entry (&tmp, struct net_device, todo_list);
      spin_unlock (&tmp_lock);
      if (!new_dev)
            goto err;
      s_skb->dev = new_dev;
...
 switch (sk->sk_state)
 {
  case TCP_SYN_RECV:
   ..
  case TCP_LISTEN:
  ..
  case TCP_SYN_SENT:
  ..
 }
   bh_unlock_sock (sk);
...
/* send reply via Netlink */

Cheers,


      _____________________________________________________________________________ 
Ne gardez plus qu'une seule adresse mail ! Copiez vos mails vers Yahoo! Mail 
