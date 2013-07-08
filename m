From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH iproute2 v2] ipbatch: fix use of 'ip netns exec'
Date: Tue, 9 Jul 2013 00:36:45 +0100
Message-ID: <1373326605.1860.12.camel@bwh-desktop.uk.level5networks.com>
References: <20130705141639.56b47e7e@samsung-9>
	 <1373276660-14088-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <shemminger@vyatta.com>, <netdev@vger.kernel.org>,
	<junwei.zhang@6wind.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50600 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752969Ab3GHXgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 19:36:50 -0400
In-Reply-To: <1373276660-14088-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-08 at 11:44 +0200, Nicolas Dichtel wrote:
[...]
> --- a/ip/ipnetns.c
> +++ b/ip/ipnetns.c
> @@ -138,6 +138,7 @@ static int netns_exec(int argc, char **argv)
>  	const char *name, *cmd;
>  	char net_path[MAXPATHLEN];
>  	int netns;
> +	int pid, status;
>  
>  	if (argc < 1) {
>  		fprintf(stderr, "No netns name specified\n");
> @@ -185,10 +186,23 @@ static int netns_exec(int argc, char **argv)
>  	/* Setup bind mounts for config files in /etc */
>  	bind_etc(name);
>  
> -	if (execvp(cmd, argv + 1)  < 0)
> -		fprintf(stderr, "exec of \"%s\" failed: %s\n",
> -			cmd, strerror(errno));
> -	return EXIT_FAILURE;
> +	pid = fork();
> +	if (pid < 0)
> +		return EXIT_FAILURE;

On failure, this should emit an error message:
		perror("fork");
and then return -1, surely?

> +	else if (pid > 0)
> +		waitpid(pid, &status, 0);
> +	else {
> +		/* Child */
> +		if (execvp(cmd, argv + 1)  < 0)
> +			fprintf(stderr, "exec of \"%s\" failed: %s\n",
> +				cmd, strerror(errno));
> +		return EXIT_FAILURE;

No, the child must not return from this function.  Otherwise there will
be two processes trying to do the same cleanup on the resources that
they still share.  The child should call _exit(127) if exec*() fails.

> +	}
> +	/* ip must returns the status of the child, but do_cmd() will add a
> +	 * minus to this returned value, so let's add another one here to
> +	 * cancel it.
> +	 */
> +	return -WEXITSTATUS(status);
>  }
>  
>  static int is_pid(const char *str)

WEXITSTATUS() is valid only if waitpid() was successful and WIFEXITED()
yields true.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
