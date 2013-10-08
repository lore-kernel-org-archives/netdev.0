From: Neal Cardwell <ncardwell@google.com>
Subject: Re: IPv6 kernel warning
Date: Tue, 8 Oct 2013 10:05:51 -0400
Message-ID: <CADVnQynJVvFesFYp68N5kzCJJD3-NXPZUUMfkg8m=or4eaLzMQ@mail.gmail.com>
References: <20130920131153.GF12758@n2100.arm.linux.org.uk>
	<20130920160830.GA4241@marquez.int.rhx>
	<CAK6E8=eNFG0fic+NYeQBjEoUQMeZKSAT3LU0JSQyE-4i_cDaZQ@mail.gmail.com>
	<alpine.DEB.2.02.1310071111240.17658@dtop>
	<CAK6E8=czoej81t=-J=gjjyQiGVbZ0qiNKBbeRVSWYtweXfSRNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: dormando <dormando@rydia.net>,
	Michele Baldessari <michele@acksyn.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:52940 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753668Ab3JHOFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 10:05:52 -0400
Received: by mail-ee0-f52.google.com with SMTP id c41so3991202eek.39
        for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 07:05:51 -0700 (PDT)
In-Reply-To: <CAK6E8=czoej81t=-J=gjjyQiGVbZ0qiNKBbeRVSWYtweXfSRNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 7, 2013 at 3:51 PM, Yuchung Cheng <ycheng@google.com> wrote:
> I suspect tcp_process_tlp_ack() should not revert state to Open
> directly, but calling tcp_try_keep_open() instead, similar to all the
> undo processing in the tcp_fastretrans_alert(): after
> tcp_end_cwnd_reduction(), the process (E) falls back to check other
> stats before moving to CA_Open.
>
>
> index 9c62257..9012b42 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -3314,7 +3314,7 @@ static void tcp_process_tlp_ack(struct sock *sk, u32 ack,
>                         tcp_init_cwnd_reduction(sk, true);
>                         tcp_set_ca_state(sk, TCP_CA_CWR);
>                         tcp_end_cwnd_reduction(sk);
> -                       tcp_set_ca_state(sk, TCP_CA_Open);
> +                       tcp_try_keep_open(sk);
>                         NET_INC_STATS_BH(sock_net(sk),
>                                          LINUX_MIB_TCPLOSSPROBERECOVERY);
>                 }

Yes, nice catch! This looks good to me. My testing confirms that this
definitely fixes a bug when this code fires and there are segments
SACKed out. Since it will stay in CA_Disorder if there are outstanding
retransmissions, I bet it will also fix the WARN_ON(tp->retrans_out !=
0) in state TCP_CA_Open that people are seeing.

neal
