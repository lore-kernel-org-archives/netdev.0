From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2 v2] ip: Simplify executing ip cmd within network
 ns
Date: Thu, 11 Dec 2014 15:21:31 +0100
Message-ID: <20141211142131.GC1912@nanopsycho.orion>
References: <1418305103-5994-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:48064 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781AbaLKOVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 09:21:34 -0500
Received: by mail-wi0-f176.google.com with SMTP id ex7so14739328wid.3
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 06:21:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1418305103-5994-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Dec 11, 2014 at 02:38:23PM CET, vadim4j@gmail.com wrote:
>From: Vadim Kochan <vadim4j@gmail.com>
>
>Added new '-netns' option to simplify executing following cmd:
>
>    ip netns exec NETNS ip OPTIONS COMMAND OBJECT
>
>    to
>
>    ip -n[etns] NETNS OPTIONS COMMAND OBJECT
>
>e.g.:
>
>    ip -net vnet0 link add br0 type bridge
>    ip -n vnet0 link
>
>Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
>---
>Changes v1 -> v2
>    use -n[etns] option name: suggested by Nicolas Dichtel
>    changed man ip.8 page
>
> ip/ip.c        |  6 ++++++
> ip/ip_common.h |  1 +
> ip/ipnetns.c   |  2 +-
> man/man8/ip.8  | 24 +++++++++++++++++++++++-
> 4 files changed, 31 insertions(+), 2 deletions(-)
>
>diff --git a/ip/ip.c b/ip/ip.c
>index 5f759d5..f3c2cdb 100644
>--- a/ip/ip.c
>+++ b/ip/ip.c
>@@ -262,6 +262,12 @@ int main(int argc, char **argv)
> 			rcvbuf = size;
> 		} else if (matches(opt, "-help") == 0) {
> 			usage();
>+		} else if (matches(opt, "-netns") == 0) {
>+			argc--;
>+			argv++;
>+			argv[0] = argv[1];
>+			argv[1] = basename;
>+			return netns_exec(argc, argv);


Can't the same functionality be done in the same ip process, meaning
without execvp ip again? It would seem clearer to me.

How about other tools (tc,bridge,..) ? It would be nice to have the same
option there as well.



> 		} else {
> 			fprintf(stderr, "Option \"%s\" is unknown, try \"ip -help\".\n", opt);
> 			exit(-1);
>diff --git a/ip/ip_common.h b/ip/ip_common.h
>index 75bfb82..d4f7e1f 100644
>--- a/ip/ip_common.h
>+++ b/ip/ip_common.h
>@@ -88,6 +88,7 @@ struct link_util
> struct link_util *get_link_kind(const char *kind);
> struct link_util *get_link_slave_kind(const char *slave_kind);
> int get_netns_fd(const char *name);
>+int netns_exec(int argc, char **argv);
> 
> #ifndef	INFINITY_LIFE_TIME
> #define     INFINITY_LIFE_TIME      0xFFFFFFFFU
>diff --git a/ip/ipnetns.c b/ip/ipnetns.c
>index 1c8aa02..367841c 100644
>--- a/ip/ipnetns.c
>+++ b/ip/ipnetns.c
>@@ -129,7 +129,7 @@ static void bind_etc(const char *name)
> 	closedir(dir);
> }
> 
>-static int netns_exec(int argc, char **argv)
>+int netns_exec(int argc, char **argv)
> {
> 	/* Setup the proper environment for apps that are not netns
> 	 * aware, and execute a program in that environment.
>diff --git a/man/man8/ip.8 b/man/man8/ip.8
>index 2d42e98..389c808 100644
>--- a/man/man8/ip.8
>+++ b/man/man8/ip.8
>@@ -31,7 +31,8 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
> \fB\-r\fR[\fIesolve\fR] |
> \fB\-f\fR[\fIamily\fR] {
> .BR inet " | " inet6 " | " ipx " | " dnet " | " link " } | "
>-\fB\-o\fR[\fIneline\fR] }
>+\fB\-o\fR[\fIneline\fR] |
>+\fB\-n\fR[\fIetns\fR] }
> 
> 
> .SH OPTIONS
>@@ -134,6 +135,27 @@ the output.
> use the system's name resolver to print DNS names instead of
> host addresses.
> 
>+.TP
>+.BR "\-n" , " \-net" , " \-netns " <NETNS>
>+executes the following
>+.RI "[ " OPTIONS " ] " OBJECT " { " COMMAND " | "
>+.BR help " }"
>+in the specified network namespace
>+.IR NETNS .
>+Actually it just simplifies executing of:
>+
>+.B ip netns exec
>+.IR NETNS
>+.B ip
>+.RI "[ " OPTIONS " ] " OBJECT " { " COMMAND " | "
>+.BR help " }"
>+
>+to
>+
>+.B ip
>+.RI "-n[etns] " NETNS " [ " OPTIONS " ] " OBJECT " { " COMMAND " | "
>+.BR help " }"
>+
> .SH IP - COMMAND SYNTAX
> 
> .SS
>-- 
>2.1.3
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
