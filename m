From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH for 3.8] iproute2: Add "ip netns pids" and "ip netns
 identify"
Date: Tue, 27 Nov 2012 18:00:39 +0000
Message-ID: <1354039239.2701.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <87a9u4q7k9.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	<netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:14493 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755812Ab2K0SAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 13:00:47 -0500
In-Reply-To: <87a9u4q7k9.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-11-26 at 17:16 -0600, Eric W. Biederman wrote:
> Add command that go between network namespace names and process
> identifiers.  The code builds and runs agains older kernels but
> only works on Linux 3.8+ kernels where I have fixed stat to work
> properly.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
> 
> I don't know if this is too soon to send this patch to iproute as the
> kernel code that fixes stat is currently sitting in my for-next branch
> of:
> git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git
> 
> and has not hit Linus's tree yet.  Still the code runs and is harmless
> on older kernels so it should be harmless whatever happens with it.
> 
>  ip/ipnetns.c        |  141 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  man/man8/ip-netns.8 |    5 ++-
>  2 files changed, 145 insertions(+), 1 deletions(-)
> 
> diff --git a/ip/ipnetns.c b/ip/ipnetns.c
> index e41a598..c55fe3a 100644
> --- a/ip/ipnetns.c
> +++ b/ip/ipnetns.c
> @@ -13,6 +13,7 @@
>  #include <dirent.h>
>  #include <errno.h>
>  #include <unistd.h>
> +#include <ctype.h>
>  
>  #include "utils.h"
>  #include "ip_common.h"
> @@ -48,6 +49,8 @@ static void usage(void)
>  	fprintf(stderr, "Usage: ip netns list\n");
>  	fprintf(stderr, "       ip netns add NAME\n");
>  	fprintf(stderr, "       ip netns delete NAME\n");
> +	fprintf(stderr, "       ip netns identify PID\n");
> +	fprintf(stderr, "       ip netns pids NAME\n");
>  	fprintf(stderr, "       ip netns exec NAME cmd ...\n");
>  	fprintf(stderr, "       ip netns monitor\n");
>  	exit(-1);
> @@ -171,6 +174,138 @@ static int netns_exec(int argc, char **argv)
>  	exit(-1);
>  }
>  
> +static int is_pid(const char *str)
> +{
> +	int ch;
> +	for (; (ch = *str); str++) {
> +		if (!isdigit(ch))

ch must be cast to unsigned char before passing to isdigit().

> +			return 0;
> +	}
> +	return 1;
> +}
> +
> +static int netns_pids(int argc, char **argv)
> +{
> +	const char *name;
> +	char net_path[MAXPATHLEN];
> +	int netns;
> +	struct stat netst;
> +	DIR *dir;
> +	struct dirent *entry;
> +
> +	if (argc < 1) {
> +		fprintf(stderr, "No netns name specified\n");
> +		return -1;
> +	}
> +	if (argc > 1) {
> +		fprintf(stderr, "extra arguments specified\n");
> +		return -1;
> +	}

These, and many other return statements in this file which set the
process exit code, should return 1 (general failure) or 2 (user error)
rather than -1 (likely to be interpreted as command not found).

> +	name = argv[0];
> +	snprintf(net_path, sizeof(net_path), "%s/%s", NETNS_RUN_DIR, name);

No check for truncation?

> +	netns = open(net_path, O_RDONLY);

This file descriptor is leaked, though that probably doesn't really
matter.

[...]
> +static int netns_identify(int argc, char **argv)
> +{
> +	const char *pidstr;
> +	char net_path[MAXPATHLEN];
> +	int netns;
> +	struct stat netst;
> +	DIR *dir;
> +	struct dirent *entry;
> +
> +	if (argc < 1) {
> +		fprintf(stderr, "No pid specified\n");
> +		return -1;
> +	}
> +	if (argc > 1) {
> +		fprintf(stderr, "extra arguments specified\n");
> +		return -1;
> +	}
> +	pidstr = argv[0];
> +
> +	if (!is_pid(pidstr)) {
> +		fprintf(stderr, "Specified string '%s' is not a pid\n",
> +			pidstr);
> +		return -1;
> +	}
> +
> +	snprintf(net_path, sizeof(net_path), "/proc/%s/ns/net", pidstr);
> +	netns = open(net_path, O_RDONLY);
> +	if (netns < 0) {
> +		fprintf(stderr, "Cannot open network namespace: %s\n",
> +			strerror(errno));
> +		return -1;
> +	}
> +	if (fstat(netns, &netst) < 0) {
> +		fprintf(stderr, "Stat of netns failed: %s\n",
> +			strerror(errno));
> +		return -1;
> +	}
> +	dir = opendir(NETNS_RUN_DIR);
> +	if (!dir)
> +		return 0;

Shouldn't this be treated as an error?  Or, if you want it to succeed
when the kernel does not have netns functionality, then treat it as an
error if !dir && errno != ENOENT.

> +	while((entry = readdir(dir))) {
> +		char name_path[MAXPATHLEN];
> +		struct stat st;
> +
> +		if (strcmp(entry->d_name, ".") == 0)
> +			continue;
> +		if (strcmp(entry->d_name, "..") == 0)
> +			continue;
> +
> +		snprintf(name_path, sizeof(name_path), "%s/%s",	NETNS_RUN_DIR,
> +			entry->d_name);
> +
> +		if (stat(name_path, &st) != 0)
> +			continue;
> +
> +		if ((st.st_dev == netst.st_dev) &&
> +		    (st.st_ino == netst.st_ino)) {
> +			printf("%s\n", entry->d_name);
> +		}
> +	}
> +	closedir(dir);
> +	return 0;
> +	
> +}
[...]

It's a shame there isn't a more efficient way to do these lookups.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
