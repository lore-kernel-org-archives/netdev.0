From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH net-next 0/5] Ease netns management for userland
Date: Wed, 12 Dec 2012 21:54:08 +0100
Message-ID: <50C8EEF0.2010201@6wind.com>
References: <1355332630-4256-1-git-send-email-nicolas.dichtel@6wind.com> <87fw3boyxn.fsf@xmission.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, aatteka@nicira.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:51353 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755541Ab2LLUyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 15:54:12 -0500
Received: by mail-wi0-f174.google.com with SMTP id hm9so3886909wib.1
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 12:54:11 -0800 (PST)
In-Reply-To: <87fw3boyxn.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/12/2012 20:25, Eric W. Biederman a =C3=A9crit :
> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
>
>> The goal of this serie is to ease netns management by daemons. Some =
systems use
>> netns only to virtualize network stack and don't want to multiply us=
erland
>> daemons.  These system may have a lot of netns, up to 2000. We don't=
 want to
>> launch an instance of each daemons (quagga, strongswan, conntrackd, =
=2E..) for
>> each netns because it will consume a lot of ressources. Having one d=
aemon that
>> manage all netns is more efficient (mainly if there are few objects =
to manage:
>> one or two routes per netns for example).
>> Hence, one goal of this serie is to allow, for a daemon, to monitor =
netns
>> activities, thus it can open or close netlink sockets, allocating st=
ructures
>> needed to manage these netns when they are created or deleted.
>> To help to identify a netns, an index has been added to each netns.
>>
>> A new setsockopt() option is also added, to help daemons to open soc=
ket in the
>> right netns. For now, a daemon that want to open a socket in a speci=
fied netns,
>> need to call setns(CLONE_NEWNET) with a fd (not so easy to found), o=
pen the
>> socket and then call again setns() to go back in the initial netns. =
Having this
>> kind of setsockopt() will simplify operations. Obviously, this setso=
ckopt()
>> should be done enough early (is test on sk_state enough?). The first=
 target is
>> netlink socket but it can be useful for other kind of socket, it's w=
hy a add a
>> generic socket option.
>>
>> As usual, the patch against iproute2 will be sent once the patches a=
re included
>> and net-next merged. I can send it on demand.
>
> Short answer you don't need to do any of this.
>
> setns with the namespace files in /proc/<pid>/ns/net gives you more t=
han
> enough mechanism to solve this problem.  And iprout2 already supports
> all of this.
>
> And your approach creates very serious maintenances problems to the
> point I don't even want to read your patches.  What namespace do your
> namespace id's live in?
>
> A socketopt to change the namespace of a socket is nasty because sock=
ets
> changing which network namespace they are in, leads to races which
> aren't worth thinking about writing the code to handle.
>
> Longer answer.
>
> You can bind mount the namespace id's /proc/<pid>/ns/net files to
> give you any name you want.  This puts naming policy in userspace
> control, and nests just fine.
>
> You can open a socket in any network namespace you want just
> by calling setns before socket.  Wrapping this idiom in a library cal=
l
> or if there is sufficient need in a socketat system call seems
> reasonable.
Yes, I agree that this SO_NETNS may be a bad idea.

>
> There is a classic question of if two network namespace files refer t=
o
> the same network namespace and I have code in linux-next and my pull
> request to Linus to give those files a unique inode number.
Interesseting to know that.

>
> So please use the facilities already merged into the kernel.
Ok, but how can a daemon get the list of netns? Suppose that we want th=
at
quagga manage all netns, how can it get this list to open needed netlin=
k
socket?
=46or example, iproute2 is only aware of netns created with iproute2, b=
ut it
will no detect other netns.
