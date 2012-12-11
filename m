From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Tue, 11 Dec 2012 14:36:33 -0800 (PST)
Message-ID: <alpine.OSX.2.00.1212111432430.78903@animac.local>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com> <3246.1351717319@obiwan.sandelman.ca> <CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com> <87mwyi9h1x.fsf@xmission.com>
Reply-To: ani@aristanetworks.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Michael Richardson <mcr@sandelman.ca>, netdev@vger.kernel.org,
	tcpdump-workers@lists.tcpdump.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:62090 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754203Ab2LKWgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 17:36:45 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so1878711dak.19
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2012 14:36:45 -0800 (PST)
In-Reply-To: <87mwyi9h1x.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> It is possible to test for the presence of support of the new vlan bpf
> extensions by attempting to load a filter that uses them.  As only valid
> filters can be loaded, old kernels that do not support filtering of vlan
> tags will fail to load the a test filter with uses them.

Unfortunately I do not see this. The sk_chk_filter() does not have a
default in the case statement and the check will not detect an unknown
instruction. It will fail when the filter is run and as far as I can see,
the packet will be dropped. Something like this might help?

diff --git a/net/core/filter.c b/net/core/filter.c
index c23543c..96338aa 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -548,6 +548,8 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 			return -EINVAL;
 		/* Some instructions need special checks */
 		switch (code) {
+		/* for unknown instruction, return EINVAL */
+		default : return -EINVAL;
 		case BPF_S_ALU_DIV_K:
 			/* check for division by zero */
 			if (ftest->k == 0)
