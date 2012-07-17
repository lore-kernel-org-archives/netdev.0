From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2] sctp: Fix list corruption resulting from freeing an
 association on a list
Date: Tue, 17 Jul 2012 08:25:27 -0400
Message-ID: <20120717122527.GA10485@hmsreliant.think-freely.org>
References: <1342463970-7457-1-git-send-email-nhorman@tuxdriver.com>
 <1342466031-18025-1-git-send-email-nhorman@tuxdriver.com>
 <20120716.223250.2238626170464909220.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davej@redhat.com, vyasevich@gmail.com,
	sri@us.ibm.com, linux-sctp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35914 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752526Ab2GQMZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 08:25:42 -0400
Content-Disposition: inline
In-Reply-To: <20120716.223250.2238626170464909220.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 16, 2012 at 10:32:50PM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Mon, 16 Jul 2012 15:13:51 -0400
> 
> > A few days ago Dave Jones reported this oops:
>  ...
> > It appears from his analysis and some staring at the code that this is likely
> > occuring because an association is getting freed while still on the
> > sctp_assoc_hashtable.  As a result, we get a gpf when traversing the hashtable
> > while a freed node corrupts part of the list.
> > 
> > Nominally I would think that an mibalanced refcount was responsible for this,
> > but I can't seem to find any obvious imbalance.  What I did note however was
> > that the two places where we create an association using
> > sctp_primitive_ASSOCIATE (__sctp_connect and sctp_sendmsg), have failure paths
> > which free a newly created association after calling sctp_primitive_ASSOCIATE.
> > sctp_primitive_ASSOCIATE brings us into the sctp_sf_do_prm_asoc path, which
> > issues a SCTP_CMD_NEW_ASOC side effect, which in turn adds a new association to
> > the aforementioned hash table.  the sctp command interpreter that process side
> > effects has not way to unwind previously processed commands, so freeing the
> > association from the __sctp_connect or sctp_sendmsg error path would lead to a
> > freed association remaining on this hash table.
> > 
> > I've fixed this but modifying sctp_[un]hash_established to use hlist_del_init,
> > which allows us to proerly use hlist_unhashed to check if the node is on a
> > hashlist safely during a delete.  That in turn alows us to safely call
> > sctp_unhash_established in the __sctp_connect and sctp_sendmsg error paths
> > before freeing them, regardles of what the associations state is on the hash
> > list.
> > 
> > I noted, while I was doing this, that the __sctp_unhash_endpoint was using
> > hlist_unhsashed in a simmilar fashion, but never nullified any removed nodes
> > pointers to make that function work properly, so I fixed that up in a simmilar
> > fashion.
> > 
> > I attempted to test this using a virtual guest running the SCTP_RR test from
> > netperf in a loop while running the trinity fuzzer, both in a loop.  I wasn't
> > able to recreate the problem prior to this fix, nor was I able to trigger the
> > failure after (neither of which I suppose is suprising).  Given the trace above
> > however, I think its likely that this is what we hit.
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > Reported-by: davej@redhat.com
> 
> Looks great, applied and queued up for -stable, thanks Neil.
> 

Thanks Dave!
Neil
