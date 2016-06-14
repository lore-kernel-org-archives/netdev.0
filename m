From: Andrey Vagin <avagin@virtuozzo.com>
Subject: Re: [CRIU] TCP_REPAIR MSS issue
Date: Tue, 14 Jun 2016 10:15:29 -0700
Message-ID: <20160614171528.GA14276@outlook.office365.com>
References: <C6D17923-7965-4483-8604-C654BFF1E0FF@netapp.com>
 <575FEA4B.2000603@virtuozzo.com>
 <3758708E-B5DE-4D8B-A8CC-37346F994B32@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Cc: Pavel Emelyanov <xemul@virtuozzo.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"criu@openvz.org" <criu@openvz.org>,
	"Honda, Michio" <michio@netapp.com>
To: "Eggert, Lars" <lars@netapp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0138.outbound.protection.outlook.com ([157.55.234.138]:46000
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751029AbcFNRax (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 13:30:53 -0400
Content-Disposition: inline
In-Reply-To: <3758708E-B5DE-4D8B-A8CC-37346F994B32@netapp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Recently we found that we have to restore more parameters for tcp
sockets.
https://patchwork.kernel.org/patch/9144995/

As for your problem, criu saves and restores mss_clamp. Could you check
that it works for your case?

on dump:
	static int tcp_stream_get_options(int sk, struct tcp_info *ti,
	TcpStreamEntry *tse)
	{
		int ret;
		socklen_t auxl;
		int val;

		auxl = sizeof(tse->mss_clamp);
		ret = getsockopt(sk, SOL_TCP, TCP_MAXSEG, &tse->mss_clamp, &auxl);
		if (ret < 0)
			goto err_sopt;

on restore:
        pr_debug("Will set mss clamp to %u\n", tse->mss_clamp);
        opts[onr].opt_code = TCPOPT_MAXSEG;
        opts[onr].opt_val = tse->mss_clamp;
        onr++;

        if (setsockopt(sk, SOL_TCP, TCP_REPAIR_OPTIONS,
                                opts, onr * sizeof(struct tcp_repair_opt)) < 0) {
                pr_perror("Can't repair options");
                return -1;
        }

Thanks,
Andrew

On Tue, Jun 14, 2016 at 11:40:01AM +0000, Eggert, Lars wrote:
> On 2016-06-14, at 13:28, Pavel Emelyanov <xemul@virtuozzo.com> wrote:
> > Andrey (in Cc) has played with TCP_REPAIR recently, I guess he can know something.
> 
> Thanks for CC'ing him. We looked a little bit more into this:
> 
> When TCP_REPAIR is on, tcp_connect() directly calls tcp_finish_connect() before returning, passing NULL for skb, which causes sk_rx_dst_set() to be bypassed. Later, when TCP_REPAIR is being turned off, do_tcp_setsockopt() just does tcp_send_window_probe(), but apparently all the "dst" stuff is being bypassed then also, so the mss remains at TCP_MSS_DEFAULT.
> 
> Lars
