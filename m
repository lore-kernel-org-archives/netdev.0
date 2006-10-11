From: David Miller <davem@davemloft.net>
Subject: Re: Dropping NETIF_F_SG since no checksum feature.
Date: Tue, 10 Oct 2006 19:15:47 -0700 (PDT)
Message-ID: <20061010.191547.83619974.davem@davemloft.net>
References: <20061010104315.61540986@freekitty>
	<20061011001338.GA30093@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, openib-general@openib.org,
	rolandd@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28570
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932333AbWJKCPo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 22:15:44 -0400
To: mst@mellanox.co.il
In-Reply-To: <20061011001338.GA30093@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Date: Wed, 11 Oct 2006 02:13:38 +0200

> Maybe I can patch linux to allow SG without checksum?
> Dave, maybe you could drop a hint or two on whether this is worthwhile
> and what are the issues that need addressing to make this work?
> 
> I imagine it's not just the matter of changing net/core/dev.c :).

You can't, it's a quality of implementation issue.  We sendfile()
pages directly out of the filesystem page cache without any
blocking of modifications to the page contents, and the only way
that works is if the card computes the checksum for us.

If we sendfile() a page directly, we must compute a correct checksum
no matter what the contents.  We can't do this on the cpu before the
data hits the device because another thread of execution can go in and
modify the page contents which would invalidate the checksum and thus
invalidating the packet.  We cannot allow this.

Blocking modifications is too expensive, so that's not an option
either.

