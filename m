From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH 2/3] rhashtable-test: retry insert operations in threads
Date: Sat, 29 Aug 2015 11:07:01 +0200
Message-ID: <20150829090701.GN20760@orbit.nwl.cc>
References: <1440757685-14241-1-git-send-email-phil@nwl.cc>
 <1440757685-14241-2-git-send-email-phil@nwl.cc>
 <20150828110929.GI32206@pox.localdomain>
 <20150828111320.GL20760@orbit.nwl.cc>
 <20150828133437.GM20760@orbit.nwl.cc>
 <20150828224303.GD32001@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com,
	wfg@linux.intel.com, lkp@01.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150828224303.GD32001@pox.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 29, 2015 at 12:43:03AM +0200, Thomas Graf wrote:
> On 08/28/15 at 03:34pm, Phil Sutter wrote:
> > Quite ugly, IMHO: rhashtable_insert_fast() may return -ENOMEM as
> > non-permanent error, if allocation in GFP_ATOMIC failed. In this case,
> > allocation in GFP_KERNEL is retried by rht_deferred_worker(). Sadly,
> > there is no way to determine if that has already been tried and failed.
> > 
> > The thread test triggers GFP_ATOMIC allocation failure quite easily, so
> > I can't really just ignore this issue. :)
> 
> Return EBUSY or ENOBUFS in the non-permanent case? It is definitely
> helpful if the API allows to differ between permanent and
> non-permanent errors.

Yes, indeed. Therefore rht_deferred_worker() needs to check the return
value of rhashtable_expand(). The question is how to propagate the error
condition, as the worker's return value is not being kept track of
(function returns void even).

Should we introduce a new field to struct rhashtable to track the
internal state? This might allow to clean up some rather obscure tests,
e.g. whether a table resize is in progress or not.

Cheers, Phil
