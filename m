From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: Re: [PATCH net 3/5] fm10k: Implement ndo_gso_check()
Date: Fri, 7 Nov 2014 01:07:36 +0000
Message-ID: <D0814FB9.5EA7E%matthew.vick@intel.com>
References: <1415138202-1197-1-git-send-email-joestringer@nicira.com>
 <1415138202-1197-4-git-send-email-joestringer@nicira.com>
 <545AE2C8.3070705@gmail.com> <20141106184115.GB18339@gmail.com>
 <20141106211522.GA55313@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "sathya.perla@emulex.com" <sathya.perla@emulex.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Linux NICS <Linux-nics@isotope.jf.intel.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	"shahed.shaikh@qlogic.com" <shahed.shaikh@qlogic.com>,
	"therbert@google.com" <therbert@google.com>
To: Joe Stringer <joestringer@nicira.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dept-GELinuxNICDev@qlogic.com" <Dept-GELinuxNICDev@qlogic.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141106211522.GA55313@gmail.com>
Content-Language: en-US
Content-ID: <BFF876E937C96540B709FDC5D2883580@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/6/14, 1:15 PM, "Joe Stringer" <joestringer@nicira.com> wrote:

>Oh, I suppose we need to check the gso_type too. More like this?
>
>+static bool fm10k_gso_check(struct sk_buff *skb, struct net_device *dev)
>+{
>+       if ((skb_shinfo(skb)->gso_type & (SKB_GSO_UDP_TUNNEL |
>SKB_GSO_GRE)) &&
>+           !fm10k_tx_encap_offload(skb))
>+               return false;
>+
>+       return true;
>+}

It seems like the skb_shinfo(skb)->gso_type check should be in some more
generic ndo_gso_check that drivers can default to/extend. Then, we could
end up with something like

static bool fm10k_gso_check(struct sk_buff *skb, struct net_device *dev)
{
	if (skb_gso_check(skb, dev) && !fm10k_tx_encap_offload(skb))
		return false;

	return true;
}

This could even be simplified and still legible as

static bool fm10k_gso_check(struct sk_buff *skb, struct net_device *dev)
{
	return !(skb_gso_check(skb, dev) && !fm10k_tx_encap_offload(skb));
}

What do you think of this approach?
