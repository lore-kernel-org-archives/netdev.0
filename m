From: Abdelrhman Ahmed <ab@abahmed.com>
Subject: Re: [PATCH] net: Reset skb to network header in neigh_hh_output
Date: Wed, 26 Oct 2016 18:53:39 +0200
Message-ID: <15801e95765.f826e84d266359.4807464957002677781@abahmed.com>
References: <1579f7f0f4f.114457ec828613.4349884782265574217@abahmed.com>
         <1475874656.28155.268.camel@edumazet-glaptop3.roam.corp.google.com>
         <157fe46f382.10e50a6d8188917.494328765811573491@abahmed.com> <1477440742.7065.161.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem" <davem@davemloft.net>, "netdev" <netdev@vger.kernel.org>,
        "linux-kernel" <linux-kernel@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477440742.7065.161.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think it's at the right place as the current one is a little different from the
commit e1f165032c8bade3a6bdf546f8faf61fda4dd01c.

In the next lines, skb_push is called after copying the hardware header and there
is no change to the data pointer inside the retry loop. We only need to reset
before this loop.

__skb_pull(skb, skb_network_offset(skb));

do {
	seq = read_seqbegin(&hh->hh_lock);
	hh_len = hh->hh_len;
	if (likely(hh_len <= HH_DATA_MOD)) {
		/* this is inlined by gcc */
		memcpy(skb->data - HH_DATA_MOD, hh->hh_data, HH_DATA_MOD);
	} else {
		int hh_alen = HH_DATA_ALIGN(hh_len);

		memcpy(skb->data - hh_alen, hh->hh_data, hh_alen);
	}
} while (read_seqretry(&hh->hh_lock, seq));

skb_push(skb, hh_len);

In the commit e1f165032c8bade3a6bdf546f8faf61fda4dd01c, dev_hard_header which
calls create method for adding hardware header (uses skb_push) so it was
required to reset to network header in the beginning of the retry loop.


 ---- On Wed, 26 Oct 2016 02:12:22 +0200 Eric Dumazet <eric.dumazet@gmail.com> wrote ---- 
 > On Wed, 2016-10-26 at 01:57 +0200, Abdelrhman Ahmed wrote: 
 > >  > What is the issue you want to fix exactly ?  
 > >  > Please describe the use case.  
 > >  
 > > When netfilter hook uses skb_push to add a specific header between network 
 > > header and hardware header. 
 > > For the first time(s) before caching hardware header, this header will be 
 > > removed / overwritten by hardware header due to resetting to network header. 
 > > After using the cached hardware header, this header will be kept as we do not 
 > > reset. I think this behavior is inconsistent, so we need to reset in both cases. 
 > >  
 > >  > Otherwise, your fix is in fact adding a critical bug.  
 > >  
 > > Could you explain more as it's not clear to me? 
 > >  
 >  
 > Maybe my wording was not good here. 
 >  
 > What I intended to say is that the  
 > __skb_pull(skb, skb_network_offset(skb)) might not be at the right 
 > place. 
 >  
 > Look at commit e1f165032c8bade3a6bdf546f8faf61fda4dd01c to find the 
 > reason. 
 >  
 >  
 > >  
 > >  
 > >  ---- On Fri, 07 Oct 2016 23:10:56 +0200 Eric Dumazet <eric.dumazet@gmail.com> wrote ----  
 > >  > On Fri, 2016-10-07 at 16:14 +0200, Abdelrhman Ahmed wrote:  
 > >  > > When hardware header is added without using cached one, neigh_resolve_output  
 > >  > > and neigh_connected_output reset skb to network header before adding it.  
 > >  > > When cached one is used, neigh_hh_output does not reset the skb to network  
 > >  > > header.  
 > >  > >   
 > >  > > The fix is to reset skb to network header before adding cached hardware header  
 > >  > > to keep the behavior consistent in all cases.  
 > >  >   
 > >  > What is the issue you want to fix exactly ?  
 > >  >   
 > >  > Please describe the use case.  
 > >  >   
 > >  > I highly suggest you take a look at commit  
 > >  >   
 > >  > e1f165032c8bade3a6bdf546f8faf61fda4dd01c  
 > >  > ("net: Fix skb_under_panic oops in neigh_resolve_output")  
 > >  >   
 > >  > Otherwise, your fix is in fact adding a critical bug.  
 > >  >   
 > >  >   
 > >  >  
 > >  
 >  
 >  
 > 
