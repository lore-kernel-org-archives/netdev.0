From: "Kyle Moffett" <kyle@moffetthome.net>
Subject: Re: [PATCH 0/4][RFC] netns: sysfs: add a netns suffix to net device sysfs entries
Date: Thu, 23 Oct 2008 00:14:19 -0400
Message-ID: <f73f7ab80810222114k7caffd16wbeb464c4739bfc77@mail.gmail.com>
References: <20081022152144.351965414@theryb.frec.bull.fr>
	 <m1d4hso0ym.fsf@frodo.ebiederm.org> <20081022203045.GA4633@us.ibm.com>
	 <m18wsgmji0.fsf@frodo.ebiederm.org> <20081022145507.2d1ea86c@extreme>
	 <m11vy8jl5s.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@vyatta.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	"Benjamin Thery" <benjamin.thery@bull.net>,
	netdev <netdev@vger.kernel.org>,
	"Dave Miller" <davem@davemloft.net>,
	"Greg Kroah-Hartman" <gregkh@suse.de>,
	"Al Viro" <viro@ftp.linux.org.uk>,
	"Daniel Lezcano" <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, "Tejun Heo" <htejun@gmail.com>,
	"Denis Lunev" <den@openvz.org>,
	"Linux Containers" <containers@lists.linux-foundation.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:40153 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbYJWEOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 00:14:20 -0400
Received: by rv-out-0506.google.com with SMTP id k40so143382rvb.1
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2008 21:14:19 -0700 (PDT)
In-Reply-To: <m11vy8jl5s.fsf@frodo.ebiederm.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 22, 2008 at 6:54 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Stephen Hemminger <shemminger@vyatta.com> writes:
>>> The well-known user space tools don't use /sys at all.  Modern
>>> network tools use rtnetlink (ip) old network tools use /proc/net.
>>>
>>> Very few things actually use /sys and for those things lo@1 or
>>> eth0@1 are completely useless except for implementing a FUSE
>>> mock up of sysfs.  But you don't need anything in sysfs to do
>>> that as all of the interesting information is available through
>>> /proc/net or rtnetlink.
>>
>> Lots of scripts are starting use /sys for things. It is easier to
>> parse /sys/class/net than the output of ifconfig or ip
>
> Yes.  So we need the correct values in /sys/class/net.
>
> Which is why sysfs and network namespaces do not coexist currently.

I definitely agree that "eth0@1" is a bad ide. I know for sure that a
relatively large number of system init scripts poke about in
/sys/class/net/$IFACE, as well as a number of the system installation
scripts.  Those scripts include some that my company has written for
internal use and others supplied by distributions.

Daemons and such mostly use netlink, but for anything written in shell
it's much easier to do things like this:

for devpath in /sys/class/net/*; do
    dev="${dev##/sys/class/net/}"
    case "${dev}" in
        [....]
    esac
    if [ "x${mac}" = "x$(cat ${devpath}/address)" ]; then
        echo "Found MAC '${mac}': ${dev}"
    fi
done

If I wanted to perform similar things with the output of ifconfig, it
would involve some much more fragile manual text parsing of the output
of the "ip" or "ifconfig" commands.  And sometimes the "ifconfig"
command is outright wrong.  If you have an interface name longer than
7 characters or so then some versions of ifconfig will truncate it
internally and display garbage.

While the "show only the root namespace" interim solution is
problematic for processes in network namespaces, I think it's more
important not to break things for admin tools in the root namespace.

Cheers,
Kyle Moffett
