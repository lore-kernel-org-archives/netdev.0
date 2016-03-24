From: Jesse Gross <jesse@kernel.org>
Subject: Re: [RFC PATCH 1/9] ipv4/GRO: Allow multiple frames to use the same
 IP ID
Date: Wed, 23 Mar 2016 18:43:40 -0700
Message-ID: <CAEh+42ir0ich=MyEtr7NkKiUBhE7Md_AF8YzQ2bCv=cy=5ziFg@mail.gmail.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain> <20160318232444.14955.38133.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Edward Cree <ecree@solarflare.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:34867 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753193AbcCXBn7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2016 21:43:59 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 02B9620374
	for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 01:43:57 +0000 (UTC)
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 27A01202E5
	for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 01:43:55 +0000 (UTC)
Received: by mail-qk0-f182.google.com with SMTP id p130so14474917qke.1
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 18:43:55 -0700 (PDT)
In-Reply-To: <20160318232444.14955.38133.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 18, 2016 at 4:24 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> In RFC 6864 it is stated that we can essentially ignore the IPv4 ID field
> if we have not and will not use fragmentation.  Such a frame is defined
> as having the DF flag set to 1, and the MF and frag_offset as 0.  Currently
> for GRO we were requiring that the inner header always have an increasing
> IPv4 ID, but we are ignoring the outer value.
>
> This patch is a first step in trying to reverse some of that.  Specifically
> what this patch does is allow us to coalesce frames that have a static IPv4
> ID value.  So for example if we had a series of frames where the DF flag
> was set we would allow the same IPv4 ID value to be used for all the frames
> belonging to that flow.  This would become the standard behavior for TCP so
> it would support either a fixed IPv4 ID value, or one in which the value
> increments.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

One thing that is a bit odd is that the TSO output procedure stays the
same. So that means that if we get a stream of packets with the DF bit
set and a constant IP ID, aggregate them with GRO, and the retransmit
with GSO/TSO then we'll get packets with IDs that increment for each
burst and then start back again to the original value. I guess it
doesn't matter in practice since the IDs are supposed to be ignored
but it does seem a little strange - especially because the new packets
will now be violating the rules of the same GRO implementation that
produced them.
