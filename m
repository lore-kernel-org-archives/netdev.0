From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v1 2/2] bridge: export multicast database via
 netlink
Date: Fri, 30 Nov 2012 15:27:33 +0000
Message-ID: <20121130152733.GH30697@casper.infradead.org>
References: <1354269514-1863-1-git-send-email-amwang@redhat.com>
 <1354269514-1863-2-git-send-email-amwang@redhat.com>
 <20121130112618.GF30697@casper.infradead.org>
 <1354287652.19865.10.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:43079 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933130Ab2K3P1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 10:27:37 -0500
Content-Disposition: inline
In-Reply-To: <1354287652.19865.10.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/12 at 11:00pm, Cong Wang wrote:
> I don't understand this. nla_put_flag() is used to put a flag (only one
> bit set) into a netlink message, so why should we use it to put
> p->port_no here? And why port_no 0 matters here?

nla_put_flag() will simply add a netlink attribute with no payload,
i.e. just the header. Assuming that port_no == 0 is invalid the
port_no can be used as attribute id as both are 16bit integers.

It will look like this:

MDBA_ROUTERS = {
  {
    .nla_len = 4,
    .nla_type = <port_no_1>,
  },
  {
    .nla_len = 4,
    .nla_type = <port_no_2>,
  }
  [...]
}

If you ever need to extend this you can just add payload to the
per port attribute and nothing will break.

> So I should use net->dev_base_seq + mdb->seq ?

No you can't, mdb->seq is not stable throughout a dump. What you
can do is save mdb->seq in cb->args[] and in case you continue
dumping from the same mdb in the next call to your dump function
you check if it changed and bump cb->seq if it did to trigger an
interrupt.
