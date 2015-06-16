From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [RFC PATCH 0/2] sctp: add new getsockopt option SCTP_SOCKOPT_PEELOFF_KERNEL
Date: Tue, 16 Jun 2015 19:42:31 -0300
Message-ID: <cover.1434492495.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35442 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754418AbbFPWmk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2015 18:42:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm trying to remove a direct dependency of dlm module on sctp one.
Currently dlm code is calling sctp_do_peeloff() directly and only this
call is causing the load of sctp module together with dlm. For that, we
have basically 3 options:
- Doing a module split on dlm
  - which I'm avoiding because it was already split and was merged (more
    info on patch2 changelog)
  - and the sctp code on it is rather small if compared with sctp module
    itself
- Using some other infra that gets indirectly activated, like getsockopt()
  - It was like this before, but the exposed sockopt created a file
    descriptor for the new socket and that create some serious issues.
    More info on 2f2d76cc3e93 ("dlm: Do not allocate a fd for peeloff")
- Doing something like ipv6_stub (which is used by vxlan) or similar
  - but I don't feel that's a good way out here, it doesn't feel right.

So I'm approaching this by going with 2nd option again but this time
also creating a new sockopt that is only accessible for kernel users of
this protocol, so that we are safe to directly return a struct socket *
via getsockopt() results. This is the tricky part of it of this series. 

It smells hacky yes but currently most of sctp calls are wrapped behind
kernel_*(). Even if we set a flag (like netlink does) saying that this
is a kernel socket, we still have the issue of getting the function call
through and returning such non-usual return value.

I kept __user marker on sctp_getsockopt_peeloff_kernel() prototype and
its helpers just to avoid issues with static checkers.

Kernel path not really tested yet.. mainly willing to know what do you
think, is this feasible? getsockopt option only reachable by kernel
itself? Couldn't find any other like this.

Thanks,
Marcelo

Marcelo Ricardo Leitner (2):
  sctp: add new getsockopt option SCTP_SOCKOPT_PEELOFF_KERNEL
  dlm: avoid using sctp_do_peeloff directly

 fs/dlm/lowcomms.c         | 17 ++++++++---------
 include/uapi/linux/sctp.h | 12 ++++++++++++
 net/sctp/socket.c         | 39 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 59 insertions(+), 9 deletions(-)

-- 
2.4.1
