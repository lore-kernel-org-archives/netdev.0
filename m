From: Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: RE: [PATCH v1 08/12] IB/cma: Add net_dev and private data checks to
 RDMA CM
Date: Wed, 15 Jul 2015 20:27:06 +0000
Message-ID: <HE1PR05MB1418C82958B3CCF0D3531E5BB19A0@HE1PR05MB1418.eurprd05.prod.outlook.com>
References: <1434976961-27424-1-git-send-email-haggaie@mellanox.com>
 <1434976961-27424-9-git-send-email-haggaie@mellanox.com>
 <20150713181414.GJ23832@obsidianresearch.com> <55A63CAC.60603@mellanox.com>
 <20150715184934.GD23588@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150715184934.GD23588-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> From: Jason Gunthorpe [mailto:jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org]
 
> 
> > What is really missing here I guess is a mechanism that would
> > enforce containers to only use certain pkeys - perhaps with
> > something like an RDMA cgroup.  It could force containers to only
> > use approved pkeys not only with RDMA CM, but through uverbs, and
> > other user-space interfaces.
> 
> Ideally yes. Without that it just means you can't use pkey
> meaningfully with containers..
> 

That's why partition enforcement should be separated from namespaces.

If you want to restrict a container to a specific set of pkeys, use cgroups.
This would apply both to CM MADs and QPs.
- In the MAD case, CM MADs would be first matched to a namespace and rdma_id and dropped upon pkey conflict (with either the headers or the payload).
- In the QP case, modify_qp() would fail on conflict.
Partitioning needs to be enforced also for applications that don't use the CM at all...

For namespaces, it seems more natural to lookup the namespace based solely on the CM payload.
After all, it is the payload that designates the entity that you want to establish a connection to, rather than the packet headers, which are just meant to relay the packet to the proper CM agent. (Spec-wise, it is even possible to use completely different node to open a connection on behalf of another node.)
So, the sole role of pkeys in the context of namespaces is to locate the proper namespace; not for partition isolation.

So, as a first step, let's get the namespace lookup in place.
Next, add an rdma crgoup, which would control pkeys, as well as resource counts (you don't want one container to rob the whole system from all QPs...).

> Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
