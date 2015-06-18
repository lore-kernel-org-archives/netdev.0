From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 04/11] IB/cm: Expose DGID in SIDR request events
Date: Thu, 18 Jun 2015 13:41:05 +0300
Message-ID: <5582A041.6060504@mellanox.com>
References: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
 <1434358036-15526-5-git-send-email-haggaie@mellanox.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FF5A3F@ORSMSX109.amr.corp.intel.com>
 <20150615220852.GB4384@obsidianresearch.com> <55800793.4040103@mellanox.com>
 <20150617170612.GB27232@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150617170612.GB27232-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 17/06/2015 20:06, Jason Gunthorpe wrote:
> On Tue, Jun 16, 2015 at 02:25:07PM +0300, Haggai Eran wrote:

>> Regarding APM, currently the ib_cm code always sends the GMP to the
>> primary path anyway, right? And in any case, one would expect the
>> primary path's GID to have a valid net_device and local routing rules,
>> so I think for the purpose of demuxing and validating the request using
>> the primary path should be fine.
> 
> The current code works that way, but it is not what I'd expect
> generally.
> 
> For instance, future APM support will be able to drive dual-rail and
> policy will decide which rail is the current best rail for data
> transfer. So the GMP may be directed to the IPoIB device with port 1,
> but the data transfer may happen on the RDMA port 2. [Note, I already
> have very rough patches that do this de-coupling]
> 
>> Why do you think the GMP's net_device should be used over the one of the
>> future RDMA channel?
> 
> The code needs to match the incoming GMP with the logical netdev that
> rx's *that GMP*. The fact that goes on to setup an RDMA channel is not
> relevant, the nature of the future RDMA channel should not impact how
> the GMP is recieved.

>From what I understand, ib_cm and rdma_cm keeps their own addresses. I
thought that ib_cm's addresses would be used to handle GMPs, and the
rdma_cm addresses (id.route.addr) to represent the created RDMA channel.
After all, that is what ucma_query_addr returns. So are you proposing
that we use the logical netdev that was resolved by the GMP to fill up
the source address returned to user-space? It sounds like it would
prevent the APM usage you described above.

> 
>> So far we can work without GRH for CM requests, and also without GRH for
>> SIDR requests if we rely on layer 3 for the interface resolution. I'm
>> not against adding a LLADDR to the protocol somehow, but I don't think
>> we should abandon all these use cases and the interoperability with
>> existing software.
> 
> Well, there is a middle ground. Lets say we get the LLADDR in the GMP
> somehow, then we get 100% correct operation when it is present.
> 
> For degraded operation we have the (device,port,pkey) and possibly
> (device,port,pkey,gid) if there was a GRH. We also have the IP address
> hack.
> 
> So, I'd say, search in this sequence:
>  - If the LLADDR is present, just find the right netdev
>  - Otherwise search for (device,port,pkey) / (device,port,pkey,gid)
>    If there is only one match then that is unambiguously the correct
>    device to use.
>  - Repeat the above search, but add the IP address. This is the hack
>    we perform for compatibility.
> 
> There is no reason to hackily look at the GMP path parameters if we are
> relying on #3 above as the hack to save us in the legacy ambiguous case.
> 
> .. and to answer your question in the other email, I think we should
> keep the hack clearly distinct from the proper operation (in fact,
> perhaps it should be user configurable). So #3 should be a distinct
> step taken when all else fails, not integrated into earlier steps.
> 
> So, this series as it stands just needs to do #2/#3 above and you guys
> can figure out the LLADDR business later.

Okay. I can add a first search without the IP address.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
