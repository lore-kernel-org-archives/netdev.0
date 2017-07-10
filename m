From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH] netns: avoid directory traversal (was: ip netns: Make
 sure netns name is sane)
Date: Mon, 10 Jul 2017 15:07:44 +0200
Message-ID: <20170710130744.GC16375@orbyte.nwl.cc>
References: <20170710120831.9355-1-mcroce@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>
To: Matteo Croce <mcroce@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:52273 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753538AbdGJNHq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Jul 2017 09:07:46 -0400
Content-Disposition: inline
In-Reply-To: <20170710120831.9355-1-mcroce@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Matteo,

On Mon, Jul 10, 2017 at 02:08:31PM +0200, Matteo Croce wrote:
> I noticed that your patch still leaves an uncovered scenario, the one where the
> namespace name is "." or "..".
> Calling 'ip netns del ..' will remove /var/run which is a symlink to /run on
> most systems causing some daemons, eg. dbus, to fail.

Oh, indeed. My patch even checks the name for 'ip netns add' only!

> ip netns doesn't validate input, allowing creation and deletion of files
> relatives to /var/run/netns.
> This patch denies creation or deletion of namespaces with names contaning
> "/" or that matches exactly "." or "..".

You might want to have a look at --scissors option to git-am for a more
elegant way of sending a reply with attached patch.

[...]
>  int do_netns(int argc, char **argv)
>  {
>  	netns_nsid_socket_init();
> @@ -775,6 +780,11 @@ int do_netns(int argc, char **argv)
>  		return netns_list(0, NULL);
>  	}
>  
> +	if (argc > 1 && invalid_name(argv[1])) {
> +		fprintf(stderr, "Invalid netns name \"%s\"\n", argv[1]);
> +		exit(-1);
> +	}

Maybe worth noting, this assumes argv[1] will be used for the netns name
which doesn't hold for 'ip netns identify' command. It doesn't matter
though, since netns_identify() enforces the parameter to be either
"self" or a decimal number. Yet, in future a new subcommand might be
added which requires this check to be refactored.

Thanks, Phil
