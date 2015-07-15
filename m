From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 0/2] Avoid link dependency of dlm on sctp module
Date: Wed, 15 Jul 2015 09:57:14 -0400
Message-ID: <20150715135714.GB24091@hmsreliant.think-freely.org>
References: <cover.1436891629.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	linux-sctp@vger.kernel.org
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37157 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169AbbGON5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 09:57:19 -0400
Content-Disposition: inline
In-Reply-To: <cover.1436891629.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 14, 2015 at 02:13:23PM -0300, Marcelo Ricardo Leitner wrote:
> Hi,
> 
> I'm trying to remove a direct dependency of dlm module on sctp one.
> Currently dlm code is calling sctp_do_peeloff() directly and this call
> only is causing the load of sctp module together with dlm. For that, we
> have basically 3 options:
> - Doing a module split on dlm
>   - which I'm avoiding because it was already split and was merged (more
>     info on patch2 changelog)
>   - and the sctp code on it is rather small if compared with sctp module
>     itself
> - Using some other infra that gets indirectly activated, like getsockopt()
>   - It was like this before, but the exposed sockopt created a file
>     descriptor for the new socket and that create some serious issues.
>     More info on 2f2d76cc3e93 ("dlm: Do not allocate a fd for peeloff")
> - Doing something like ipv6_stub (which is used by vxlan) or similar
>   - but I don't feel that's a good way out here, it doesn't feel right.
> 
> So I'm approaching this by going with 2nd option again but this time
> also creating a new sockopt that is only accessible for kernel users of
> this protocol, so that we are safe to directly return a struct socket *
> via getsockopt() results.
> 
> "Kernel users" are identified by sockets that don't have a file
> descriptor attached to it, as only kernel users are allowed to do that
> and, if original socket has a file descriptor, one should just use the
> original option.
> 
> I kept __user marker on sctp_getsockopt_peeloff_kernel() prototype and
> its helpers just to avoid issues with static checkers.
> 
> I tried minimizing the code duplication while adding the new option, but
> it's just better to add a whole new function to handle it. As the
> sockopt arguments are different, the only thing in common between both
> call handlers is the call to sctp_do_peeloff(). All rest would have to
> have checks around it.
> 
> RFC->v1, from Neil:
>  - For identifying kernel users, switched from segment_eq() to fd check
>  - Reused original option to avoid code duplication
> v1->v2, from David:
>  - Back to new sockopt implementation, to avoid changing sockopt arg
>    format.
> 
> 
> Marcelo Ricardo Leitner (2):
>   sctp: add new getsockopt option SCTP_SOCKOPT_PEELOFF_KERNEL
>   dlm: avoid using sctp_do_peeloff directly
> 
>  fs/dlm/lowcomms.c         | 17 ++++++++---------
>  include/uapi/linux/sctp.h | 12 ++++++++++++
>  net/sctp/socket.c         | 37 +++++++++++++++++++++++++++++++++++++
>  3 files changed, 57 insertions(+), 9 deletions(-)
> 
> -- 
> 2.4.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Series
Acked-by: Neil Horman <nhorman@tuxdriver.com>
