From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] macvtap: add namespace support to the sysfs device class
Date: Mon, 25 Apr 2016 14:12:32 -0500
Message-ID: <8737q933kv.fsf@x220.int.ebiederm.org>
References: <1461161491-22867-1-git-send-email-marc@arista.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: Marc Angel <marc@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:33467 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933365AbcDYTXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 15:23:03 -0400
In-Reply-To: <1461161491-22867-1-git-send-email-marc@arista.com> (Marc Angel's
	message of "Wed, 20 Apr 2016 16:11:31 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marc Angel <marc@arista.com> writes:

> When creating macvtaps that are expected to have the same ifindex
> in different network namespaces, only the first one will succeed.
> The others will fail with a sysfs_warn_dup warning due to them trying
> to create the following sysfs link (with 'NN' the ifindex of macvtapX):
>
> /sys/class/macvtap/tapNN -> /sys/devices/virtual/net/macvtapX/tapNN
>
> This is reproducible by running the following commands:
>
> ip netns add ns1
> ip netns add ns2
> ip link add veth0 type veth peer name veth1
> ip link set veth0 netns ns1
> ip link set veth1 netns ns2
> ip netns exec ns1 ip l add link veth0 macvtap0 type macvtap
> ip netns exec ns2 ip l add link veth1 macvtap1 type macvtap
>
> The last command will fail with "RTNETLINK answers: File exists" (along
> with the kernel warning) but retrying it will work because the ifindex
> was incremented.

Yes.  That is totally broken, and you would not even care excpect that
the ifindex maintained separately per network namespace.  Useful for
migration but it totally breaks things in this case.

> The 'net' device class is isolated between network namespaces so each
> one has its own hierarchy of net devices.
> This isn't the case for the 'macvtap' device class.
> The problem occurs half-way through the netdev registration, when
> `macvtap_device_event` is called-back to create the 'tapNN' macvtap
> class device under the 'macvtapX' net class device.
>
> This patch adds namespace support the the 'macvtap' device class so
> that /sys/class/macvtap is no longer shared between net namespaces.
>
> However, doing this has the side effect of changing
> /sys/devices/virtual/net/macvtapX/tapNN  into
> /sys/devices/virtual/net/macvtapX/macvtap/tapNN

I forget the details of how this interface works, but
/sys/devices/virtual/net is definitely allows different overlapping
content per network namespace, so we should not need to add an extra
directory to make this work.

> This is due to Commit 24b1442 ("Driver-core: Always create class
> directories for classses that support namespaces.")
>
> Signed-off-by: Marc Angel <marc@arista.com>
> ---
> I'm not sure that the problems described in that commit message
> apply to macvtaps so maybe it is possible to keep the 'tapNN'
> device directly under 'macvtapX' and not disrupt userland.
>
> Should it even be possible to add a device of a class that doesn't
> support namespaces under one that does?
> This could lead to dead symlinks in the new device class directory or
> duplicate warnings because a device of the same name already exists in
> another namespace.

This definitely looks like something that bears digging into, and fixing
properly.

Eric
