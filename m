From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH] openvswitch: allow management from inside user namespaces
Date: Mon, 1 Feb 2016 12:50:26 -0800
Message-ID: <CAOrHB_DAtYm-s5Lc-EpSAxXDZHPzgXzcyZhwiYtg=zT=LTrgWg@mail.gmail.com>
References: <1454072433-20137-1-git-send-email-tycho.andersen@canonical.com>
	<8760yccvbw.fsf@x220.int.ebiederm.org>
	<20160129163744.GA3558@hopstrocity>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	containers@lists.linux-foundation.org,
	Justin Pettit <jpettit@nicira.com>
To: Tycho Andersen <tycho.andersen@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:54974 "EHLO
	relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753334AbcBAUuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 15:50:32 -0500
In-Reply-To: <20160129163744.GA3558@hopstrocity>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 29, 2016 at 8:37 AM, Tycho Andersen
<tycho.andersen@canonical.com> wrote:
> Hi Eric,
>
> Thanks for the review.
>
> On Fri, Jan 29, 2016 at 08:29:55AM -0600, Eric W. Biederman wrote:
>> Tycho Andersen <tycho.andersen@canonical.com> writes:
>>
>> > Operations with the GENL_ADMIN_PERM flag fail permissions checks because
>> > this flag means we call netlink_capable, which uses the init user ns.
>> >
>> > Instead, let's do permissions checks in each function, but use the netlink
>> > socket's user ns instead of the initial one, to allow management of
>> > openvswitch resources from inside a user ns.
>> >
>> > The motivation for this is to be able to run openvswitch in unprivileged
>> > containers. I've tested this and it seems to work, but I really have no
>> > idea about the security consequences of this patch, so thoughts would be
>> > much appreciated.
>>
>> So at a quick look using ns_capable this way is probably buggy.
>>
>> netlink is goofy (because historically we got this wrong), and I forget
>> what the specific rules are.  The general rule is that you need to do
>> your permission checks on open/create/connect and not inside send/write
>> while processing data.  Otherwise there is a class of privileged
>> applications where you can set their stdout to some precreated file
>> descriptor and their output can be made to act as a command, bypassing
>> your permission checks.
>
> It's worth noting that this patch doesn't move the checks (i.e., they
> are still done at write time currently in the kernel), it just relaxes
> them to root in the user ns instead of real root. This means I can
> currently exploit netlink this way as an unprivileged, just not from
> within an unprivileged container.
>
> An alternate version of this patch below might be more favorable, as
> we may want to do something like this elsewhere in netlink. I think it
> also clarifies the situation a bit, at the cost of adding another
> flag.
>
> A third option would be to move this check to connect time, but that
> would force everything in the family (since that's the only thing you
> connect /to/ in netlink) to have the same required permissions, which
> might (probably?) break stuff; e.g. you can call OVS_FLOW_CMD_GET
> without CAP_NET_ADMIN, but if we changed everything in the family to
> require it, that would break.
>
> Tycho
> ---
>  include/uapi/linux/genetlink.h |  1 +
>  net/netlink/genetlink.c        |  6 ++++--
>  net/openvswitch/datapath.c     | 20 ++++++++++----------
>  3 files changed, 15 insertions(+), 12 deletions(-)
>
> diff --git a/include/uapi/linux/genetlink.h b/include/uapi/linux/genetlink.h
> index c3363ba..5512c90 100644
> --- a/include/uapi/linux/genetlink.h
> +++ b/include/uapi/linux/genetlink.h
> @@ -21,6 +21,7 @@ struct genlmsghdr {
>  #define GENL_CMD_CAP_DO                0x02
>  #define GENL_CMD_CAP_DUMP      0x04
>  #define GENL_CMD_CAP_HASPOL    0x08
> +#define GENL_UNS_ADMIN_PERM    0x10
>
This approach looks good to me.
