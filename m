From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH 1/2] net: Disable segmentation if checksumming is not supported
Date: Mon, 2 May 2016 09:48:09 -0700
Message-ID: <CAKgT0UdaaXNX=G052vjC+JVZG8MGyHKPMMxK-U5Zgn8FiENNPg@mail.gmail.com>
References: <20160502161621.11701.9271.stgit@ahduyck-xeon-server>
	<20160502162510.11701.82922.stgit@ahduyck-xeon-server>
	<CALx6S36=dHesn65aWWiiC=rRjmOW3mZa3ymk0oq5JBncg6SEnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:36264 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753598AbcEBQsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 12:48:10 -0400
Received: by mail-ig0-f169.google.com with SMTP id u10so89839905igr.1
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 09:48:10 -0700 (PDT)
In-Reply-To: <CALx6S36=dHesn65aWWiiC=rRjmOW3mZa3ymk0oq5JBncg6SEnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 2, 2016 at 9:33 AM, Tom Herbert <tom@herbertland.com> wrote:
> On Mon, May 2, 2016 at 9:25 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
>> In the case of the mlx4 and mlx5 driver they do not support IPv6 checksum
>> offload for tunnels.  With this being the case we should disable GSO in
>> addition to the checksum offload features when we find that a device cannot
>> perform a checksum on a given packet type.
>>
> I'm not sure I understand this. If device can't support checksum
> offload for tunnels doesn't that mean we have to do the checksum on
> host regardless of whether GSO is being done?

The use of the term GSO here might be the confusing part.  Basically
the issue is the hardware advertises it can do TSO for IPv4 on
encapsulated frames, however it doesn't indicate it can do IPv6
checksum offload.  So what ends up happening is that in the case of a
v4 over v6 tunnel we were going through validate_xmit_skb which will
check things in netif_skb_features and come out supporting the TSO but
no checksums.  As a result we would fall through and hit
skb_checksum_help and trigger the warn on in there because we had TSO
requested even though we couldn't do the checksum.

Basically I am just extending the kind of logic we have in
netdev_fix_features so that if we cannot support checksumming the
frame then we cannot support segmenting it.

- Alex
