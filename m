From: =?iso-8859-1?Q?Andr=E1s_Tak=E1cs?= <linux-kernel@wakoond.hu>
Subject: xfrm warning by mip6d
Date: Wed, 5 Oct 2011 11:22:22 +0200
Message-ID: <4C76ADDE-B534-4C40-BBDA-DCADA5DD347D@wakoond.hu>
Mime-Version: 1.0 (Apple Message framework v1244.3)
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:48756 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934140Ab1JEJWZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 05:22:25 -0400
Received: by bkbzt4 with SMTP id zt4so1868887bkb.19
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2011 02:22:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear All,

We're running mip6d mobile IPv6 daemon on 2.6.35.13 kernel. While it is=
 sending periodic Binding Update messages via raw IPv6 socket the follo=
wing warning message appears:

[  946.883714] ------------[ cut here ]------------
[  946.883714] WARNING: at trunk/kernel/linux-2.6.35.13/include/linux/s=
kbuff.h:447 skb_dst.clone.22+0x42/0x44()
[  946.883714] Hardware name: Bochs
[  946.890048] Modules linked in: xfrm_user
[  946.890179] Pid: 523, comm: mip6d Tainted: G        W   2.6.35.13-it=
ssv6 #1
[  946.890270] Call Trace:
[  946.890354]  [<c0130e75>] warn_slowpath_common+0x65/0x7a
[  946.890453]  [<c03e2b11>] ? skb_dst.clone.22+0x42/0x44
[  946.890553]  [<c0130e99>] warn_slowpath_null+0xf/0x13
[  946.890651]  [<c03e2b11>] skb_dst.clone.22+0x42/0x44
[  946.890748]  [<c03e2e04>] ip6_finish_output2+0x15/0x23c
[  946.890847]  [<c0130e99>] ? warn_slowpath_null+0xf/0x13
[  946.890947]  [<c03e438f>] ip6_finish_output+0x8b3/0x8bf
[  946.891048]  [<c0130c9c>] ? print_oops_end_marker+0x1e/0x23
[  946.891151]  [<c0130e82>] ? warn_slowpath_common+0x72/0x7a
[  946.891248]  [<c03e2b11>] ? skb_dst.clone.22+0x42/0x44
[  946.891346]  [<c0130e99>] ? warn_slowpath_null+0xf/0x13
[  946.891445]  [<c03e4443>] ip6_output+0xa8/0xb0
[  946.891539]  [<c03dd551>] xfrm_output_resume+0x99/0x349
[  946.891639]  [<c03dd80e>] xfrm_output2+0xd/0xf
[  946.891732]  [<c03dd8a6>] xfrm_output+0x96/0xa0
[  946.891828]  [<c0404fbf>] xfrm6_output_finish+0x13/0x15
[  946.891928]  [<c04050fc>] xfrm6_output+0x4a/0x52
[  946.892020]  [<c03e2b28>] dst_output+0x15/0x18
[  946.892111]  [<c03e33b0>] ip6_local_out+0x17/0x1a
[  946.892206]  [<c03e502c>] ip6_push_pending_frames+0x27c/0x31f
[  946.892314]  [<c03f62f7>] rawv6_sendmsg+0xa79/0xb0b
[  946.892411]  [<c014e7ad>] ? __lock_acquire+0x54f/0xbdc
[  946.892525]  [<c03c932d>] inet_sendmsg+0x3d/0x46
[  946.892623]  [<c0383b2f>] __sock_sendmsg+0x45/0x4e
[  946.892722]  [<c0383f8f>] sock_sendmsg+0x92/0xa6
[  946.892822]  [<c014eec2>] ? lock_release_non_nested+0x88/0x1f7
[  946.892927]  [<c0177f81>] ? might_fault+0x46/0x80
[  946.893023]  [<c0177f81>] ? might_fault+0x46/0x80
[  946.893121]  [<c024a690>] ? _copy_from_user+0x39/0x4d
[  946.893221]  [<c0385656>] sys_sendmsg+0x17d/0x1e1
[  946.893331]  [<c014eec2>] ? lock_release_non_nested+0x88/0x1f7
[  946.893436]  [<c0177f81>] ? might_fault+0x46/0x80
[  946.893531]  [<c0177f81>] ? might_fault+0x46/0x80
[  946.893628]  [<c0385a28>] sys_socketcall+0x14b/0x189
[  946.893725]  [<c024a130>] ? trace_hardirqs_on_thunk+0xc/0x10
[  946.893827]  [<c0119b17>] sysenter_do_call+0x12/0x36
[  946.893915] ---[ end trace a2273a766b3b014c ]---

I tried to find the issue, and printed out the three condition values o=
f WARN_ON macro:

[   61.686487] debug skb->_skb_refdst: 00000000CED5EA01 SKB_DST_NOREF 0=
000000000000001 =3D=3D> 0000000000000001
[   61.686649] rcu_read_lock_held() 0
[   61.686730] rcu_read_lock_bh_held() 0

I think, that the issue is somewhere in the xfrm module, which includes=
 the Home Address Destination Option header, before ip6_output.


Did anyone have the same issue before? Where do you thing the missing r=
cu lock is?


Thank you very much!

Regards,
Andr=E1s Tak=E1cs
http://www.wakoond.hu
