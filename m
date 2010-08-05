From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch] isdn: fix information leak
Date: Thu, 5 Aug 2010 15:55:11 +0200
Message-ID: <20100805134910.GJ9031@bicker>
References: <20100805093806.GF9031@bicker> <AANLkTin4jtYuaxYfxDAgST857sD2K4Q28mPcPW=xd-V3@mail.gmail.com> <20100805101938.GH9031@bicker> <AANLkTi=8ThVqTHpQmDfoon02C-VZ0JwBRtSrU7dzvvNt@mail.gmail.com> <20100805113721.GI9031@bicker> <AANLkTikGNr8aVV7Rryq_dvSuYjUbEo_gRDLW3d49YwF-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45825 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760481Ab0HENz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 09:55:58 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTikGNr8aVV7Rryq_dvSuYjUbEo_gRDLW3d49YwF-@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First of all, I'm happy that you're reviewing these patches.  A lot of
learner, often untested, patches go through kernel-janitors and the
entire purpose of the list is to check each other's work.

Here is what I meant by an information leak.  The original code did:
	spid = kmalloc(SCIOC_SPIDSIZE, GFP_KERNEL);
	...
	strcpy(spid, rcvmsg->msg_data.byte_array);
	...
	if (copy_to_user(data->dataptr, spid, SCIOC_SPIDSIZE)) {

When you allocate memory with kmalloc() it doesn't clear that memory.  It
could have anything in there including passwords etc.  If there is a
short string in "rcvmsg->msg_data.byte_array" like "123" then the
strcpy() puts that in the first 4 bytes of "spid", but the rest of the
buffer is still full of passwords.

The copy_to_user() sends it to the user, and normally the user only reads
as far as the terminator, but if they read past that then they would see
all the passwords etc that were saved there.

This function is in the ioctl() probably only root has open() permission
on the device so it's not a big deal because root can already find your
password.  But I didn't dig that far.  It's just simpler to zero out the
memory instead of worrying about if it really is exploitable or not.

Also it's quite possible that the strcpy can't overflow.  But it's weird
for the code to leave space for the terminator and then not use it.  In
the end, I decided to do the cautious thing and be done with it.

regards,
dan carpenter
