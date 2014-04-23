From: Steve Grubb <sgrubb@redhat.com>
Subject: Re: [PATCH 0/6][v2] audit: implement multicast socket for journald
Date: Tue, 22 Apr 2014 22:25:55 -0400
Message-ID: <26389161.vp9iWSVLPX@x2>
References: <20140422.161904.1187535812839850973.davem@davemloft.net>
	<cover.1398215388.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org, linux-audit@redhat.com,
        selinux@tycho.nsa.gov, jamal@mojatatu.com, davem@davemloft.net
To: Richard Guy Briggs <rgb@redhat.com>
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <cover.1398215388.git.rgb@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/options/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Tuesday, April 22, 2014 09:31:52 PM Richard Guy Briggs wrote:
> This is a patch set Eric Paris and I have been working on to add a
> restricted capability read-only netlink multicast socket to kernel audit to
> enable userspace clients such as systemd/journald to receive audit logs, in
> addition to the bidirectional auditd userspace client.

Do have the ability to separate of secadm_r and sysadm_r? By allowing this, we 
will leak to a sysadmin that he is being audited by the security officer. In a 
lot of cases, they are one in the same person. But for others, they are not. I 
have a feeling this will cause problems for MLS systems.

Also, shouldn't we have an audit event for every attempt to connect to this 
socket? We really need to know where this information is getting leaked to.

-Steve


> Currently, auditd has the CAP_AUDIT_CONTROL and CAP_AUDIT_WRITE capabilities
> (but uses CAP_NET_ADMIN).  The CAP_AUDIT_READ capability will be added for
> use by read-only AUDIT_NLGRP_READLOG multicast group clients to the kaudit
> subsystem.  This will remove the dependence on CAP_NET_ADMIN for the
> multicast read-only socket.
> 
> 
> Patches 1-3 provide a way for per-protocol bind functions to
> signal an error and to be able to clean up after themselves.
> 
> The first netfilter cleanup patch has already been accepted by a netfilter
> maintainer, though I don't see it upstream yet, so it is included for
> completeness.
> 
> The second patch adds the per-protocol bind function return code to signal
> to the netlink code that no further processing should be done and to undo
> the work already done.
> V1: This rev fixes a bug introduced by flattening the code in the last
> posting. *V2: This rev moves the per-protocol bind call above the socket
> exposure call and refactors out the unbind procedure.
> 
> The third provides a way per protocol to undo bind actions on DROP.
> 
> 
> Patches 4-6 implement the audit multicast socket with capability checking.
> 
> The fourth patch adds the bind function capability check to multicast join
> requests for audit.
> 
> The fifth patch adds the audit log read multicast group.  An assumption has
> been made that systemd/journald reside in the initial network namespace. 
> This could be changed to check the actual network namespace of
> systemd/journald should this assumption no longer be true since audit now
> supports all network namespaces.  This version of the patch now directly
> sends the broadcast when the packet is ready rather than waiting until it
> passes the queue.
> 
> The sixth checks if any clients actually exist before sending.
> 
> 
> Since the net tree is busier than the audit tree, conflicts are more likely
> and the audit patches depend on the net patches, it is proposed to have the
> net tree carry this entire patchset for 3.16.  Are the net maintainers ok
> with this?
> 
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=887992
> 
> First posted:  
> https://www.redhat.com/archives/linux-audit/2013-January/msg00008.html
> https://lkml.org/lkml/2013/1/27/279
> 
> Please find source for a test program at:
> 	http://people.redhat.com/rbriggs/audit-multicast-listen/
> 
> 
> Richard Guy Briggs (6):
>   netlink: simplify nfnetlink_bind
>   netlink: have netlink per-protocol bind function return an error
>     code.
>   netlink: implement unbind to netlink_setsockopt
>     NETLINK_DROP_MEMBERSHIP
>   audit: add netlink audit protocol bind to check capabilities on
>     multicast join
>   audit: add netlink multicast group for log read
>   audit: send multicast messages only if there are listeners
> 
>  include/linux/netlink.h             |    3 +-
>  include/uapi/linux/audit.h          |    8 ++++
>  include/uapi/linux/capability.h     |    7 +++-
>  kernel/audit.c                      |   64 ++++++++++++++++++++++++++++++--
> net/netfilter/nfnetlink.c           |   10 ++---
>  net/netlink/af_netlink.c            |   70
> +++++++++++++++++++++++++---------- net/netlink/af_netlink.h            |  
>  6 ++-
>  security/selinux/include/classmap.h |    2 +-
>  8 files changed, 135 insertions(+), 35 deletions(-)
