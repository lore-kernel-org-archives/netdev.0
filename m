From: JP Abgrall <jpa@google.com>
Subject: Re: [PATCH 0/2] Add UID/GID info to NFQUEUE
Date: Mon, 30 Dec 2013 14:39:30 -0800
Message-ID: <CAKP4w2SuiJej0pWF_=V0XoMuTxxPN5Do--1=wVTDxp4koNLt5w@mail.gmail.com>
References: <1387389844-5263-1-git-send-email-valentina.giusti@bmw-carit.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, tgraf@redhat.com,
	Pablo Neira Ayuso <pablo@netfilter.org>, davem@davemloft.net,
	daniel.wagner@bmw-carit.de
To: valentina.giusti@bmw-carit.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:37937 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932334Ab3L3Wjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 17:39:51 -0500
Received: by mail-oa0-f50.google.com with SMTP id n16so12667861oag.9
        for <netdev@vger.kernel.org>; Mon, 30 Dec 2013 14:39:51 -0800 (PST)
In-Reply-To: <1387389844-5263-1-git-send-email-valentina.giusti@bmw-carit.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 18, 2013 at 10:04 AM,  <valentina.giusti@bmw-carit.de> wrote:
> At the Linux Plumbers Conference 2013, there have been quite interesting
> discussions on the topic of network statistics, and it was proposed that it
> would make more sense to use NFQUEUE for this purpose, letting therefore
> userspace use the UID/GID information for application-based statistics purposes.
> This way the UID and GID information of the incoming TCP and UDP traffic is not
> "wasted" and can be used for more refined statistics.

Some things to keep in mind when doing these changes...
For mobile devices, having the UID/GID is not sufficient when services
are involved (download manager, http service, ...).
Currently, Android's xt_qtaguid netfilter module supports the notion
of "delegation" which is achieved by having the service "tag" a socket
(tracked internally based on the struct sock address), via the file
descriptor, with a UID of who should be blamed for the statistics.
It would be nice if NFQUEUE presented/tracked some data related to the
socket that could be used to that effect.
This tagging of the socket needs to have the following properties:
 - a socket can stay open and be re-tagged (happens when pools are
used or when a stream can be used for multiple reasons).
 - a socket can be tagged with a different UID only if the current
UID/GID/pcap allows for it.
 - an app can have multiple sockets, each one belonging to different
UIDs (so no UID to UID mapping).
There are a few more, but those can be managed outside of the NFQUEUE changes.

Concerning the comment about TCP_TIMEWAIT in some other thread: the sk
is not a "struct sock" but "struct inet_timewait_sock" which is
missing fields. So beware when manipulating it. xt_qtaguid had to
ignore those struct sock.
