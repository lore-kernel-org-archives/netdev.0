From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH 0/2] sctp: add new getsockopt option
 SCTP_SOCKOPT_PEELOFF_KERNEL
Date: Wed, 17 Jun 2015 14:45:53 -0400
Message-ID: <20150617184553.GA24075@hmsreliant.think-freely.org>
References: <cover.1434492495.git.marcelo.leitner@gmail.com>
 <20150617102119.GA24677@hmsreliant.think-freely.org>
 <55815C22.2000605@gmail.com>
 <20150617122004.GC24677@hmsreliant.think-freely.org>
 <55816AC0.2070508@gmail.com>
 <20150617131658.GD24677@hmsreliant.think-freely.org>
 <558178CA.3010806@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	linux-sctp@vger.kernel.org
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59598 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753216AbbFQSsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 14:48:08 -0400
Content-Disposition: inline
In-Reply-To: <558178CA.3010806@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 17, 2015 at 10:40:26AM -0300, Marcelo Ricardo Leitner wrote:
> On 17-06-2015 10:16, Neil Horman wrote:
> >On Wed, Jun 17, 2015 at 09:40:32AM -0300, Marcelo Ricardo Leitner wrote:
> >>On 17-06-2015 09:20, Neil Horman wrote:
> >>>On Wed, Jun 17, 2015 at 08:38:10AM -0300, Marcelo Ricardo Leitner wrote:
> >>>>On 17-06-2015 07:21, Neil Horman wrote:
> >>>>>On Tue, Jun 16, 2015 at 07:42:31PM -0300, Marcelo Ricardo Leitner wrote:
> >>>>>>Hi,
> >>>>>>
> >>>>>>I'm trying to remove a direct dependency of dlm module on sctp one.
> >>>>>>Currently dlm code is calling sctp_do_peeloff() directly and only this
> >>>>>>call is causing the load of sctp module together with dlm. For that, we
> >>>>>>have basically 3 options:
> >>>>>>- Doing a module split on dlm
> >>>>>>   - which I'm avoiding because it was already split and was merged (more
> >>>>>>     info on patch2 changelog)
> >>>>>>   - and the sctp code on it is rather small if compared with sctp module
> >>>>>>     itself
> >>>>>>- Using some other infra that gets indirectly activated, like getsockopt()
> >>>>>>   - It was like this before, but the exposed sockopt created a file
> >>>>>>     descriptor for the new socket and that create some serious issues.
> >>>>>>     More info on 2f2d76cc3e93 ("dlm: Do not allocate a fd for peeloff")
> >>>>>>- Doing something like ipv6_stub (which is used by vxlan) or similar
> >>>>>>   - but I don't feel that's a good way out here, it doesn't feel right.
> >>>>>>
> >>>>>>So I'm approaching this by going with 2nd option again but this time
> >>>>>>also creating a new sockopt that is only accessible for kernel users of
> >>>>>>this protocol, so that we are safe to directly return a struct socket *
> >>>>>>via getsockopt() results. This is the tricky part of it of this series.
> >>>>>>
> >>>>>>It smells hacky yes but currently most of sctp calls are wrapped behind
> >>>>>>kernel_*(). Even if we set a flag (like netlink does) saying that this
> >>>>>>is a kernel socket, we still have the issue of getting the function call
> >>>>>>through and returning such non-usual return value.
> >>>>>>
> >>>>>>I kept __user marker on sctp_getsockopt_peeloff_kernel() prototype and
> >>>>>>its helpers just to avoid issues with static checkers.
> >>>>>>
> >>>>>>Kernel path not really tested yet.. mainly willing to know what do you
> >>>>>>think, is this feasible? getsockopt option only reachable by kernel
> >>>>>>itself? Couldn't find any other like this.
> >>>>>>
> >>>>>>Thanks,
> >>>>>>Marcelo
> >>>>>>
> >>>>>>Marcelo Ricardo Leitner (2):
> >>>>>>   sctp: add new getsockopt option SCTP_SOCKOPT_PEELOFF_KERNEL
> >>>>>>   dlm: avoid using sctp_do_peeloff directly
> >>>>>>
> >>>>>>  fs/dlm/lowcomms.c         | 17 ++++++++---------
> >>>>>>  include/uapi/linux/sctp.h | 12 ++++++++++++
> >>>>>>  net/sctp/socket.c         | 39 +++++++++++++++++++++++++++++++++++++++
> >>>>>>  3 files changed, 59 insertions(+), 9 deletions(-)
> >>>>>>
> >>>>>>--
> >>>>>>2.4.1
> >>>>>>
> >>>>>>
> >>>>>
> >>>>>Why not just use the existing PEELOFF socket option with the kernel_getsockopt
> >>>>>interface, and sockfd_lookup to translate the returned value back to a socket
> >>>>>struct?  That seems less redundant and less hack-ish to me.
> >>>>
> >>>>It was like that before commit 2f2d76cc3e93 ("dlm: Do not allocate a fd for
> >>>>peeloff"), but it caused serious issues due to the fd allocation, so that's
> >>>>what I'm willing to avoid now.
> >>>>
> >>>>References:
> >>>>http://article.gmane.org/gmane.linux.network.drbd/22529
> >>>>https://bugzilla.redhat.com/show_bug.cgi?id=1075629 (this one is closed,
> >>>>sorry)
> >>>>
> >>>>   Marcelo
> >>>>
> >>>Ah, I see.  You're using the new socket option as a differentiator to just skip
> >>>the creation of an FD.
> >>
> >>Exactly.
> >>
> >>>I get your reasoning, but I'm still not in love with the idea of duplicating
> >>>code paths to avoid that action.  Can we use some data inside the socket
> >>>structure to do this differentiation?  Specifically here I'm thinking of
> >>>sock->file.  IIRC that will be non-null for any sockets created in user space,
> >>
> >>I had thought about using some socket flags like netlink does but couldn't
> >>get around with that. Hadn't thought about sock->file though, nice idea.
> >>
> >>>but will always be NULL for dlm created sockets (since we use sock_create
> >>>directly to create them.  If that is a sufficient differentiator, then we can
> >>>just optionally allocate the new socket fd for the peeled off socket, iff the
> >>>parent sock->file pointer is non-null.
> >>>
> >>>Thoughts?
> >>>Neil
> >>
> >>We can re-use the current code path, by either checking it via sock->file or
> >>via get_fs(). That will require us to change the option arg format so we
> >>keep it nice and clean but as it would be kernel-side only, it should be ok
> >>right? It currently is:
> >>
> >>typedef struct {
> >>         sctp_assoc_t associd;
> >>         int sd;
> >>} sctp_peeloff_arg_t;
> >>
> >>And we would have to fit a pointer in there, something like:
> >>typedef union {
> >>	struct {
> >>	        sctp_assoc_t associd;
> >>	        int sd;
> >>	};
> >>	void *sock;
> >>} sctp_peeloff_arg_t;
> >>
> >>Sounds good?
> >>
> >Yes, sounds reasonable.
> >
> >Thanks!
> >Neil
> 
> Cool, thanks Neil. I'll rework these now but will post the new version
> probably by next week only, as we can get dlm properly tested too.
> 
Worksforme :)
Neil

> Cheers,
> Marcelo
> 
> 
