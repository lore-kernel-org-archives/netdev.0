From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH iproute2 v4] ipbatch: fix use of 'ip netns exec'
Date: Tue, 9 Jul 2013 17:19:24 +0100
Message-ID: <1373386764.2523.1.camel@bwh-desktop.uk.level5networks.com>
References: <1373376013.4979.148.camel@edumazet-glaptop>
	 <1373385312-4899-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <eric.dumazet@gmail.com>, <shemminger@vyatta.com>,
	<netdev@vger.kernel.org>, <junwei.zhang@6wind.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:9495 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980Ab3GIQT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jul 2013 12:19:29 -0400
In-Reply-To: <1373385312-4899-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-09 at 17:55 +0200, Nicolas Dichtel wrote:
[...]
> diff --git a/ip/ipnetns.c b/ip/ipnetns.c
> index fa2b681..cdc3101 100644
> --- a/ip/ipnetns.c
> +++ b/ip/ipnetns.c
> @@ -42,6 +42,7 @@
>  #define MS_SHARED	(1 << 20)
>  #endif
>  
> +extern char *batch_file;

Should be declared in a header file.

>  #ifndef HAVE_SETNS
>  static int setns(int fd, int nstype)
> @@ -185,6 +186,42 @@ static int netns_exec(int argc, char **argv)
>  	/* Setup bind mounts for config files in /etc */
>  	bind_etc(name);
>  
> +	if (batch_file) {
> +		int status;
> +		pid_t pid;
> +
> +		pid = fork();
> +		if (pid < 0) {
> +			perror("fork");
> +			return EXIT_FAILURE;

return -1;

> +		}
> +
> +		if (pid == 0) {
> +			/* Child */
> +			if (execvp(cmd, argv + 1)  < 0)
> +				fprintf(stderr, "exec of \"%s\" failed: %s\n",
> +					cmd, strerror(errno));
> +
> +			_exit(EXIT_FAILURE);
> +		}
> +
> +		/* Parent */
> +		if (waitpid(pid, &status, 0) < 0) {
> +			perror("waitpid");
> +			return EXIT_FAILURE;

return -1;

> +		}
> +
> +		if (WIFEXITED(status)) {
> +			/* ip must returns the status of the child, but do_cmd()
> +			 * will add a minus to this returned value, so let's add
> +			 * another one here to cancel it.
> +			 */
> +			return -WEXITSTATUS(status);
> +		}
> +
> +		return EXIT_FAILURE;

return -1;

> +	}
> +
>  	if (execvp(cmd, argv + 1)  < 0)
>  		fprintf(stderr, "exec of \"%s\" failed: %s\n",
>  			cmd, strerror(errno));

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
