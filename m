From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC net-next 1/3] bonding: add infrastructure for an option
 API
Date: Fri, 10 Jan 2014 11:19:14 -0800
Message-ID: <20140110111914.6b33b650@nehalam.linuxnetplumber.net>
References: <1389359495-9700-1-git-send-email-nikolay@redhat.com>
	<1389359495-9700-2-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:64775 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbaAJTTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 14:19:17 -0500
Received: by mail-pa0-f52.google.com with SMTP id kx10so1289212pab.11
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 11:19:17 -0800 (PST)
In-Reply-To: <1389359495-9700-2-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Jan 2014 14:11:33 +0100
Nikolay Aleksandrov <nikolay@redhat.com> wrote:

> This patch adds the necessary basic infrastructure to support
> centralized and unified option manipulation API for the bonding. The new
> structure bond_option will be used to describe each option with its
> dependencies on modes which will be checked automatically thus removing a
> lot of duplicated code. Also automatic range checking is added for
> non-string options. Currently the option setting function requires RTNL to
> be acquired prior to calling it, since many options already rely on RTNL
> it seemed like the best choice to protect all against common race
> conditions.
> In order to add an option the following steps need to be done:
> 1. Add an entry BOND_OPT_<option> to bond_options.h so it gets a unique id
>    and a bit corresponding to the id
> 2. Add a bond_option entry to the bond_opts[] array in bond_options.c which
>    describes the option, its dependencies and its manipulation function
> 3. Add code to export the option through sysfs and/or as a module parameter
>    (the sysfs export will be made automatically in the future)
> 
> The current available option types are:
> BOND_OPTVAL_INTEGER - range option, the flags should be used to define
>                       it properly
> BOND_OPTVAL_STRING - string option or an option which wants to do its
>                      own validation and conversion since the buffer is
>                      passed unmodified to the option manipulation function
> 
> The options can have different flags set, currently the following are
> supported:
> BOND_OPTFLAG_NOSLAVES - require that the bond device has no slaves prior
>                         to setting the option
> BOND_OPTFLAG_IFDOWN - require that the bond device is down prior to
>                       setting the option
> 
> There's a new value structure to describe different types of values
> which can have the following flags:
> BOND_VALFLAG_DEFAULT - marks the default option (permanent string alias
>                        to this option is "default")
> BOND_VALFLAG_MIN - the minimum value that this option can have
> BOND_VALFLAG_MAX - the maximum value that this option can have
> 
> An example would be nice here, so if we have an option which can have
> the values "off"(2), "special"(4, default) and supports a range, say
> 16 - 32, it should be defined as follows:
> "off", 2,
> "special", 4, BOND_VALFLAG_DEFAULT,
> "rangemin", 16, BOND_VALFLAG_MIN,
> "rangemax", 32, BOND_VALFLAG_MAX
> So we have the valid intervals: [2, 2], [4, 4], [16, 32]
> 
> BOND_VALFLAG_(MIN|MAX) can be used to specify a valid range for an
> option, if MIN is omitted then 0 is considered as a minimum. If an
> exact match is found in the values[] table it will be returned,
> otherwise the range is tried (if available).
> The values[] table which describes the allowed values for an option is
> not mandatory for BOND_OPTVAL_STRING, but if it's present it will be
> used.
> 
> For BOND_OPTVAL_INTEGER the values[] table is mandatory.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Please add new features via netlink not sysfs.
Sysfs is awkward API for command line, and not accessible through ip link.
Also it provides no notification of changes or configuration back to switches
and other things using netlink.
