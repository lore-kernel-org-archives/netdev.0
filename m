From: James Huang <jamesclhuang@gmail.com>
Subject: =?utf-8?b?c2tiX3NlZ21lbnQoKQ==?= questions
Date: Thu, 5 Mar 2009 00:08:38 +0000 (UTC)
Message-ID: <loom.20090305T000003-18@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:37443 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753296AbZCEAI5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2009 19:08:57 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Lf18t-00009v-0r
	for netdev@vger.kernel.org; Thu, 05 Mar 2009 00:08:51 +0000
Received: from 66.151.55.131 ([66.151.55.131])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2009 00:08:51 +0000
Received: from jamesclhuang by 66.151.55.131 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2009 00:08:51 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

    After spending hours trying to understand how GSO and GRO works in =
the=20
latest Linux kernel (net-next-2.6.git), I am still quite confused about=
=20
the implementation of skb_segment():

(1) Comments about the roles of some critical variables in the routine =
will=20
help. Among them, len, hsize, and offset are not as confusing and I fig=
ured=20
they have the following meanings:

len: amount of payload to "copy" into nskb
hsize: amount of payload to copy into nskb's head buffer=20
offset: offset (from L2 header) of skb's payload to start "copy" into n=
skb

However, the variable "pos" is quite ambiguous. The value of "pos" at t=
he=20
beginning of each iteration of the do loop seems to depend on the curre=
nt=20
fragment being processed.  If current fragment is the head buffer of sk=
b, pos=20
is set to offset(end of the head buffer).  But if the current fragment =
is a=20
page entry in skb or a skb in the frag_list, then pos is set to offset
(beginning of the current fragment).

(2) What is the purpose of the following check?

`    if (pos >=3D offset + len)
        continue;

     If the payload in the head buffer of skb has at least mss bytes, t=
his=20
check will succeed and no payload in skb=E2=80=99s head buffer will be =
copy into nskb=20
through a call to skb_copy_from_linear_data_offset(). Something seems t=
o be=20
wrong here.

(3) Variable "hsize" seems to have a new meaning within the following i=
f=20
statement:

       if (!hsize && i >=3D nfrags) {
                      :
                      :
	   hsize =3D skb_end_pointer(nskb) - nskb->head;
	   if (skb_cow_head(nskb, doffset + headroom)) {
	 	kfree_skb(nskb);
		goto err;
	   }

	   nskb->truesize +=3D skb_end_pointer(nskb) - nskb->head -=20
hsize;                :
                      :
       }

    If so, it will be better to use a different variable here.

(4) When will the if condition (if (pos < offset + len)) just before=20
skip_faglist become true?  When the if condition is true, nskb will hav=
e a non-
null frag_list. How do we know that the output interface's driver will =
support=20
such a skb?

(5) There are some assumptions about the input skb. These assumptions a=
re=20
asserted by BUG_ON() statements throughout the routine.  It will help t=
o list=20
those assumptions at the very beginning of skb_segment().


Thanks,
James Huang



