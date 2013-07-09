From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2 v3] ipbatch: fix use of 'ip netns exec'
Date: Tue, 09 Jul 2013 06:20:13 -0700
Message-ID: <1373376013.4979.148.camel@edumazet-glaptop>
References: <1373326605.1860.12.camel@bwh-desktop.uk.level5networks.com>
	 <1373365612-16402-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, junwei.zhang@6wind.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:35299 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752553Ab3GINUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jul 2013 09:20:15 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so5520706pbb.22
        for <netdev@vger.kernel.org>; Tue, 09 Jul 2013 06:20:15 -0700 (PDT)
In-Reply-To: <1373365612-16402-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-09 at 12:26 +0200, Nicolas Dichtel wrote:
> From: JunweiZhang <junwei.zhang@6wind.com>
> 
> execvp() does not return when the command succeed, hence all commands in the
> batch file after the line 'ip netns exec' are not executed.
> 
> Let's fork before calling execvp().
> 
> Example:
> $ cat test.batch
> netns add netns1
> netns exec netns1 ip l
> netns
> $ ip -b test.batch
> 1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
> 2: sit0: <NOARP> mtu 1480 qdisc noop state DOWN mode DEFAULT
>     link/sit 0.0.0.0 brd 0.0.0.0
> 
> All command after 'netns exec' are never executed.
> 
> With the patch:
> $ ip -b test.batch
> 1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
> 2: sit0: <NOARP> mtu 1480 qdisc noop state DOWN mode DEFAULT
>     link/sit 0.0.0.0 brd 0.0.0.0
> netns1
> 
> Now, existing netns are displayed.
> 
> Signed-off-by: JunweiZhang <junwei.zhang@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
> 
> v3: be more verbose on error (fork(), waitpid())
>     when child fails, just exit to avoid double cleanning
>     check WIFEXITED() and waitpid() before using WEXITSTATUS()
> 
> v2: keep exit status of the child
>     add an example in the commit log
> 
>  ip/ipnetns.c | 30 +++++++++++++++++++++++++++---
>  1 file changed, 27 insertions(+), 3 deletions(-)
> 
> diff --git a/ip/ipnetns.c b/ip/ipnetns.c
> index fa2b681..474a296 100644
> --- a/ip/ipnetns.c
> +++ b/ip/ipnetns.c
> @@ -138,6 +138,7 @@ static int netns_exec(int argc, char **argv)
>  	const char *name, *cmd;
>  	char net_path[MAXPATHLEN];
>  	int netns;
> +	int pid, status;

	pid_t pid;

>  
>  	if (argc < 1) {
>  		fprintf(stderr, "No netns name specified\n");
> @@ -185,9 +186,32 @@ static int netns_exec(int argc, char **argv)
>  	/* Setup bind mounts for config files in /etc */
>  	bind_etc(name);
>  
> -	if (execvp(cmd, argv + 1)  < 0)
> -		fprintf(stderr, "exec of \"%s\" failed: %s\n",
> -			cmd, strerror(errno));
> +	pid = fork();
> +	if (pid < 0) {
> +		perror("fork");
> +		return EXIT_FAILURE;
> +	} else if (pid == 0) {
> +		/* Child */
> +		if (execvp(cmd, argv + 1)  < 0)
> +			fprintf(stderr, "exec of \"%s\" failed: %s\n",
> +				cmd, strerror(errno));
> +		exit(EXIT_FAILURE);

	_exit(EXIT_FAILURE);

Or else you could have buffered data in stdout buffer, and it will be
emitted twice.
