From: Jesse Gross <jesse@kernel.org>
Subject: Re: [RFC PATCH 07/11] GENEVE: Add option to mangle IP IDs on inner
 headers when using TSO
Date: Thu, 7 Apr 2016 20:22:57 -0300
Message-ID: <CAEh+42jyh0EWwaOAu3KNSQKEv3NRgjPT_4QRYUmLRSXtsMgWJw@mail.gmail.com>
References: <20160407222211.11142.41024.stgit@ahduyck-xeon-server> <20160407223237.11142.33072.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: herbert@gondor.apana.org.au, Tom Herbert <tom@herbertland.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	edumazet@google.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:49403 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751818AbcDGXXP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 19:23:15 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 64A9120263
	for <netdev@vger.kernel.org>; Thu,  7 Apr 2016 23:23:14 +0000 (UTC)
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 968D120222
	for <netdev@vger.kernel.org>; Thu,  7 Apr 2016 23:23:12 +0000 (UTC)
Received: by mail-qg0-f45.google.com with SMTP id f52so77389095qga.3
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 16:23:12 -0700 (PDT)
In-Reply-To: <20160407223237.11142.33072.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 7, 2016 at 7:32 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This patch adds support for a feature I am calling IP ID mangling.  It is
> basically just another way of saying the IP IDs that are transmitted by the
> tunnel may not match up with what would normally be expected.  Specifically
> what will happen is in the case of TSO the IP IDs on the headers will be a
> fixed value so a given TSO will repeat the same inner IP ID value gso_segs
> number of times.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

If I'm understanding this correctly, enabling IP ID mangling will help
performance on ixgbe since it will allow it to do GSO partial instead
of plain GSO but it will hurt performance on i40e since it will drop
from TSO to plain GSO.

Assuming that's right, it seems like it will make it hard to chose the
right setting without knowledge of which hardware is in use. I guess
what we really want is "I care about nicely incrementing IP IDs" vs.
"I don't care as long as the DF bit is set". That second case is
really what this flag is trying to say but it seems like it is
enforcing too much in the i40e case - I don't think anyone wants to go
out of their way to make IP IDs jump around if incrementing is faster.
