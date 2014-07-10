From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 0/5] SCTP updates
Date: Thu, 10 Jul 2014 11:37:19 +0200
Message-ID: <53BE5ECF.3050202@redhat.com>
References: <20140708111408.GA23026@hmsreliant.think-freely.org> <53BBFAA6.80408@redhat.com> <20140708144127.GB23026@hmsreliant.think-freely.org> <53BD1211.4080504@redhat.com> <20140709104958.GA3784@hmsreliant.think-freely.org> <53BD4363.70306@redhat.com> <20140709151354.GA5250@localhost.localdomain> <53BD6167.1030000@gmail.com> <20140709154428.GD5250@localhost.localdomain> <53BD6EB7.7070302@gmail.com> <20140709183508.GB14509@hmsreliant.think-freely.org> <063D6719AE5E284EB5DD2968C1650D6D1726FBA0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'Neil Horman'" <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"geirola@gmail.com" <geirola@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30101 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752234AbaGJJhf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2014 05:37:35 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1726FBA0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/2014 11:02 AM, David Laight wrote:
> From: Neil Horman
> ...
>>> No there is not direct overlap between the two.  However, as Michael pointed out,
>>> there is a new option to control SCTP_RCVINFO.  So would could add a deprecation
>>> warning to the over SCTP_EVENTS option and carry SCTP_SNDRCVINFO with it.
>>> Once SCTP_EVENTS goes away so can SCTP_SNDRCVINFO.
>>>
>> Ok, so we should still consider deprecation warnings then.  Daniel, what about
>> ratelimited warnings with pids included then?
>
> Can you defer any deprecation warnings for a few kernel versions?
> This gives time for applications to be recoded.

I am fine either way, adding the warning a bit later seems fine, too.

Right now, even in-kernel users like dlm would hit it if we include
it immediately.

Otherwise, I'll just add something like the below ...

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index d95a50c..6a0e5a4 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2205,8 +2205,13 @@ static int sctp_setsockopt_events(struct sock *sk, char __user *optval,
  	if (copy_from_user(&sctp_sk(sk)->subscribe, optval, optlen))
  		return -EFAULT;

-	/*
-	 * At the time when a user app subscribes to SCTP_SENDER_DRY_EVENT,
+	if (sctp_sk(sk)->subscribe.sctp_data_io_event)
+		pr_warn_ratelimited(DEPRECATED "%s (pid %d) "
+				    "Requested SCTP_SNDRCVINFO event.\n"
+				    "Use SCTP_RCVINFO through SCTP_RECVRCVINFO option instead.\n",
+				    current->comm, task_pid_nr(current));
+
+	/* At the time when a user app subscribes to SCTP_SENDER_DRY_EVENT,
  	 * if there is no data to be sent or retransmit, the stack will
  	 * immediately send up this notification.
  	 */

> Including argv[0] (even just the exec-time value) is much more use than the pid.
>
> Actually this is 'right PITA' for an application.
> A program binary that needs to work with old and new kernels will have to
> try the new option, and if it fails fall back to the old one, and then
> conditionally create/inspect the cmsg data.
> I can't actually imagine anyone bothering!
>
> Our sctp code is actually in a kernel module, so we can look at the kernel
> version when (part of) the driver is compiled on the target system.
>
> 	David
>
>
>
