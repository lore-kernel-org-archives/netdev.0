From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCH net 3/5] fm10k: Implement ndo_gso_check()
Date: Fri, 7 Nov 2014 14:35:56 -0800
Message-ID: <201411071435.56628.joestringer@nicira.com>
References: <1415138202-1197-1-git-send-email-joestringer@nicira.com> <201411071805.18119.joestringer@nicira.com> <D0825758.5EC90%matthew.vick@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dept-GELinuxNICDev@qlogic.com" <Dept-GELinuxNICDev@qlogic.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"sathya.perla@emulex.com" <sathya.perla@emulex.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Linux NICS <Linux-nics@intel.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	"shahed.shaikh@qlogic.com" <shahed.shaikh@qlogic.com>,
	"therbert@google.com" <therbert@google.com>,
	"Or Gerlitz" <gerlitz.or@gmail.com>
To: "Vick, Matthew" <matthew.vick@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <D0825758.5EC90%matthew.vick@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, November 07, 2014 11:49:38 Vick, Matthew wrote:
> On 11/6/14, 9:05 PM, "Joe Stringer" <joestringer@nicira.com> wrote:
> >Let's merge both discussions into one thread (pick here or there). We
> >have
> >this suggestion or the one which simply checks for tunnels and
> >inner+outer
> >header lengths. Do you have a preference between them?
> 
> Agreed with merging the thread--consider it merged!
> 
> Reflecting on this some more, I prefer the latter option (checking tunnels
> and header lengths). I'm leaning towards pushing the header length check
> into fm10k_tx_encap_offload and then making fm10k_gso_check call that with
> the gso_type. So, it's really the most recent version of the patch you
> proposed:
> 
> static bool fm10k_gso_check(struct sk_buff *skb, struct net_device *dev)
> {
> 	if ((skb_shinfo(skb)->gso_type & (SKB_GSO_UDP_TUNNEL | SKB_GSO_GRE)) &&
> 	    !fm10k_tx_encap_offload(skb))
> 		return false;
> 
> 	return true;
> }
> 
> 
> plus the header length being checked in fm10k_tx_encap_offload. The only
> nit would be that I'd just return the conditional instead of having
> "return true" or "return false" lines.

OK, that sounds reasonable.

> The tunnel length check really should be there in fm10k_tx_encap_offload
> anyway, so I'll get a patch together for that one.

Thanks.

> >We could introduce an "skb_is_gso_encap()" or similar for this purpose.
> >Checking for SKB_GSO_UDP_TUNNEL or SKB_GSO_GRE is pretty closely tied to
> >what
> >fm10k_tx_encap_offload() checks for though; it might not even make sense
> >to call
> >it if some of the other SKB_GSO_* flags are raised.
> 
> A fair point. On the other hand, we have to check the header length both
> in the GSO and non-GSO cases anyway, so only having the check in
> fm10k_tx_encap_offload and calling it from fm10k_gso_check wouldn't be as
> duplicative. What do you think about that approach?

Sure, I think fm10k_tx_encap_offload() is a good place for the header length 
check. Separately, my question above was regarding the idea of a helper for 
SKB_GSO_{GRE,UDP_TUNNEL}. The only reason it might be useful for the fm10k 
driver is because all encap is checked in the fm10k_tx_encap_offload() function. 
Other drivers don't seem to handle different tunnels together like this though, 
so I'm inclined to stick with the below for now.
                                                                                
static bool fm10k_gso_check(struct sk_buff *skb, struct net_device *dev)        
{                                                                               
        return (!(skb_shinfo(skb)->gso_type &                                   
                  (SKB_GSO_UDP_TUNNEL | SKB_GSO_GRE)) ||                        
                fm10k_tx_encap_offload(skb));                                   
}

Cheers,
Joe
