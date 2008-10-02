From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
 (fwd)
Date: Thu, 2 Oct 2008 12:42:44 +0200 (CEST)
Message-ID: <alpine.LFD.1.10.0810021142370.5549@apollo.tec.linutronix.de>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi> <48e3a4e5.0d1d640a.4cd3.06e9@mx.google.com> <alpine.LFD.1.10.0810012140360.5549@apollo.tec.linutronix.de> <48e3e835.0906c00a.2cd1.2fd1@mx.google.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-298259637-1222944166=:5549"
Cc: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-15?Q?D=E2niel_Fraga?= <fragabr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:44866 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753109AbYJBKm5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 06:42:57 -0400
In-Reply-To: <48e3e835.0906c00a.2cd1.2fd1@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-298259637-1222944166=:5549
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Wed, 1 Oct 2008, Dâniel Fraga wrote:
> On Wed, 1 Oct 2008 22:05:09 +0200 (CEST)
> Thomas Gleixner <tglx@linutronix.de> wrote:
> 
> > One possibility to get deeper insight into this problem is to use the
> > function tracer and stop it once we notice the wreckage. 
> > listenoverflow should be a good point to stop it.
> 
> 	Ok, I'm already running function tracer.
> 
> 	I did the following:
> 
> echo ftrace > /debug/tracing/current_tracer
> echo print-parent > /debug/tracing/iter_ctrl
> 
> 	Is it enough to get what you suggest?

Please add:

  echo sym-offset > /debug/tracing/iter_ctrl
  echo sym-addr > /debug/tracing/iter_ctrl
  echo sym-verbose > /debug/tracing/iter_ctrl

> 	If so, I'll leave it enabled:
> 
> echo 1 > /debug/tracing/tracing_enabled
> 
> 	and stop and get the data just when the problem happens... then
> I should know what I should grep, what's relevant.

I'm not sure, whether manual stop will be sufficient as the relevant
traces might have been gone by that time. 

Find below a patch which disables the tracer when the listen overflow
is detected. It could occassionally be hit in a legimate case as well,
but we did not come up with any better idea.

If it triggers, please cat /debug/tracing/trace to a file. Can you
bzip2 and upload it to some place. The trace does not contain any
sensible private information.

Thanks,

	tglx
---
diff --git a/kernel/trace/ftrace.c b/kernel/trace/ftrace.c
index f6e3af3..a1cecb0 100644
--- a/kernel/trace/ftrace.c
+++ b/kernel/trace/ftrace.c
@@ -68,6 +68,12 @@ static void ftrace_list_func(unsigned long ip, unsigned long parent_ip)
 	};
 }
 
+void stop_event_tracer_now(void)
+{
+	tracer_enabled = 0;
+	printk(KERN_INFO "Tracer stopped\n");
+}
+
 /**
  * clear_ftrace_function - reset the ftrace function
  *
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index f976fc5..527dd45 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -485,6 +485,8 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 	return newsk;
 }
 
+extern void stop_event_tracer_now(void);
+
 /*
  *	Process an incoming packet for SYN_RECV sockets represented
  *	as a request_sock.
@@ -687,6 +689,7 @@ struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
 	return child;
 
 listen_overflow:
+	stop_event_tracer_now();
 	if (!sysctl_tcp_abort_on_overflow) {
 		inet_rsk(req)->acked = 1;
 		return NULL;
--8323328-298259637-1222944166=:5549--
