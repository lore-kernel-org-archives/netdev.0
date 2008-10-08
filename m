From: "Michael Kerrisk" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] add a sysctl to disable TCP simultaneous connection opening
Date: Wed, 8 Oct 2008 11:19:58 +0200
Message-ID: <517f3f820810080219h3fd1ca2bkafef34fcc0f7fd6c@mail.gmail.com>
References: <20081008081109.GA25342@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Willy Tarreau" <w@1wt.eu>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081008081109.GA25342-K+wRfnb2/UA@public.gmane.org>
Content-Disposition: inline
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[CC+=linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org]

(As very recently noted in SubmittingPatches)

On Wed, Oct 8, 2008 at 10:11 AM, Willy Tarreau <w@1wt.eu> wrote:
> Hi David,
>
> I hope you had a pleasant journey in Paris last week. It was nice to meet you.
>
> In 2005, I submitted a patch for 2.6.11 which we finally did not decide
> on, it was about the ability to disable TCP simultaneous connection open.
>
> For the last few years, we've been bothered several times by newbies
> reading "TCP/IP for dummies" then trying to get a name by discovering
> the ultimate vulnerability which will get a lot of press coverage. Of
> course those attacks are often pointless or just proofs of concepts
> with no application in real life, but it's nonetheless annoying to have
> to deal with the issues, especially to explain to customers why they
> shouldn't have to worry.
>
> I would not be surprized that a next one will exploit TCP's ability to
> perform simultaneous connections between two clients. It's very easy
> to trigger, there's no SEQ to guess, just a port, and the effect is
> simply a poor DoS on the service trying to connect outside. In other
> times we would have found it very minor, but judging by the consideration
> given to harder and less effective "attacks" these days, this trivial
> one may finally get picked and annoy us again.
>
> As a reminder (especially for those who are not aware of this feature),
> it is possible with TCP to connect two clients together if both send
> crossed SYNs, then SYN-ACKs, then ACKs. This implies that each side
> accepts the sequence number of the other one without any ability to
> check that it matches its SYN. So it's trivial for an attacker to
> prevent one client from establishing a connection from a known port
> to a known address/port by sending it a SYN to that port. The client
> will then send a SYN-ACK and will not accept the expected server's
> SYN-ACK because the SYN SEQ will be different. The server might also
> send an RST on the client's SYN-ACK if it's not firewalled. The
> connection will eventually timeout in a SYN-RECV state or simply be
> aborted.
>
> The theorical DoS effect on some predictable address/port destinations
> is easy to understand. Services with very few destination IP/ports such
> as software/signature updates, SMTP relaying, DNS clients for zone
> transfers, or SSH remote accesses are easy targets. In practice, the
> SYN would have to be sent after the client's SYN and before the server's
> SYN-ACK, which leaves a small time window limiting the attack to far
> remote, unfirewalled communications.
>
> This is very easy to test, I'm used to do it between two netcats, and
> preventing the initial RST by unplugging the cable before sending the
> connects. I remember it also worked on Solaris 8, and I don't remember
> about BSDs (though I would not be surprized they support it too).
>
> IMHO this feature is totally useless nowadays, because :
>  - if one of the machines is firewalled, the firewall will block it
>    (none of the firewalls I've tested among Netfilter, Checkpoint,
>     Cisco, Fortinet, Juniper supports simultaneous connect, and it
>     would cause a big security issue).
>
>  - if neither machines are firewalled, then the SYN to a closed port
>    will immediately trigger an RST, making it very difficult to
>    establish a working connection.
>
> For this reason, I'd like that we plan on merging the attached patch
> (or any variant) for 2.6.28 or 2.6.29 before a new random junkie comes
> aroung screaming loud he uncovered a big DoS hole in Linux TCP stack. The
> patch provides a sysctl allowing the user to enable or disable the feature.
> I've been running all my kernels with the code ifdef'ed out for the last
> 4-5 years, but I certainly can understand that some people want to be able
> to enable it for any reason (even for educationnal purposes), hence the
> sysctl.
>
> I have rediffed the patch for 2.6.27-rc9 and successfully tested it (both
> with feature enabled and disabled). It disables the feature by default,
> but I have no problem with leaving it on and expecting that distros will
> ship it off.
>
> By the way, during the tests I noticed something strange. While the
> socket is in SYN_RECV on the first side to receive the other one's
> SYN, it has a huge receive queue :
>
> Active Internet connections (servers and established)
> Proto Recv-Q     Send-Q Local Address        Foreign Address      State
> tcp   3964220580      1 192.32.189.160:12346 192.32.189.228:4000  SYN_RECV
>
> The value corresponds to the ACK value emitted, which is equal to the
> other end's SYN+1. I don't know if this is just an artefact of the way
> the queue size is reported (probably because the first ACK has not yet
> been considered since we're not in ESTABLISHED state) or if this can
> have any further impact (eg: unexpected memory freeing on termination,
> etc...).
>
> Best regards,
> Willy
>
>
> From 61abc5ef6c3bc210c63036b5f36cc96a7802b605 Mon Sep 17 00:00:00 2001
> From: Willy Tarreau <w@1wt.eu>
> Date: Wed, 8 Oct 2008 10:00:42 +0200
> Subject: TCP: add a sysctl to disable simultaneous connection opening.
>
> Strict implementation of RFC793 (TCP) requires support for a feature
> called "simultaneous connect", which allows two clients to connect to
> each other without anyone entering a listening state.  While almost
> never used, and supported by few OSes, Linux supports this feature.
>
> However, it introduces a weakness in the protocol which makes it very
> easy for an attacker to prevent a client from connecting to a known
> server. The attacker only has to guess the source port to shut down
> the client connection during its establishment. The impact is limited,
> but it may be used to prevent an antivirus or IPS from fetching updates
> and not detecting an attack, or to prevent an SSL gateway from fetching
> a CRL for example.
>
> This patch provides a new sysctl "tcp_simult_connect" to enable or disable
> support for this useless feature. It comes disabled by default.
>
> Hundreds of systems running with that feature disabled for more than 4 years
> have never encountered an application which requires it. It is almost never
> supported by firewalls BTW.
>
> Signed-off-by: Willy Tarreau <w@1wt.eu>
> ---
>  Documentation/networking/ip-sysctl.txt |   22 ++++++++++++++++++++++
>  include/linux/sysctl.h                 |    1 +
>  include/net/tcp.h                      |    1 +
>  net/ipv4/sysctl_net_ipv4.c             |    8 ++++++++
>  net/ipv4/tcp_input.c                   |    5 ++++-
>  5 files changed, 36 insertions(+), 1 deletions(-)
>
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index d849326..cefc894 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -101,6 +101,28 @@ inet_peer_gc_maxtime - INTEGER
>
>  TCP variables:
>
> +tcp_simult_connect - BOOLEAN
> +       Enables TCP simultaneous connect feature conforming to RFC793.
> +       Strict implementation of RFC793 (TCP) requires support for a feature
> +       called "simultaneous connect", which allows two clients to connect to
> +       each other without anyone entering a listening state.  While almost
> +       never used, and supported by few OSes, Linux supports this feature.
> +
> +       However, it introduces a weakness in the protocol which makes it very
> +       easy for an attacker to prevent a client from connecting to a known
> +       server. The attacker only has to guess the source port to shut down
> +       the client connection during its establishment. The impact is limited,
> +       but it may be used to prevent an antivirus or IPS from fetching updates
> +       and not detecting an attack, or to prevent an SSL gateway from fetching
> +       a CRL for example.
> +
> +       If you want absolute compatibility with any possible application,
> +       you should set it to 1. If you prefer to enhance security on your
> +       systems you'd better let it to 0. After four years of usage on
> +       hundreds of systems, no application was ever found to require this
> +       feature, which is not even supported by most firewalls.
> +       Default: 0
> +
>  somaxconn - INTEGER
>        Limit of socket listen() backlog, known in userspace as SOMAXCONN.
>        Defaults to 128.  See also tcp_max_syn_backlog for additional tuning
> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> index d0437f3..0e23062 100644
> --- a/include/linux/sysctl.h
> +++ b/include/linux/sysctl.h
> @@ -435,6 +435,7 @@ enum
>        NET_TCP_ALLOWED_CONG_CONTROL=123,
>        NET_TCP_MAX_SSTHRESH=124,
>        NET_TCP_FRTO_RESPONSE=125,
> +       NET_TCP_SIMULT_CONNECT=126,
>  };
>
>  enum {
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 8983386..c61fe3c 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -236,6 +236,7 @@ extern int sysctl_tcp_base_mss;
>  extern int sysctl_tcp_workaround_signed_windows;
>  extern int sysctl_tcp_slow_start_after_idle;
>  extern int sysctl_tcp_max_ssthresh;
> +extern int sysctl_tcp_simult_connect;
>
>  extern atomic_t tcp_memory_allocated;
>  extern atomic_t tcp_sockets_allocated;
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index e0689fd..d2a73ec 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -716,6 +716,14 @@ static struct ctl_table ipv4_table[] = {
>                .proc_handler   = &proc_dointvec,
>        },
>        {
> +               .ctl_name       = NET_TCP_SIMULT_CONNECT,
> +               .procname       = "tcp_simult_connect",
> +               .data           = &sysctl_tcp_simult_connect,
> +               .maxlen         = sizeof(int),
> +               .mode           = 0644,
> +               .proc_handler   = &proc_dointvec,
> +       },
> +       {
>                .ctl_name       = CTL_UNNUMBERED,
>                .procname       = "udp_mem",
>                .data           = &sysctl_udp_mem,
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 67ccce2..932504e 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -87,6 +87,7 @@ int sysctl_tcp_max_orphans __read_mostly = NR_FILE;
>  int sysctl_tcp_frto __read_mostly = 2;
>  int sysctl_tcp_frto_response __read_mostly;
>  int sysctl_tcp_nometrics_save __read_mostly;
> +int sysctl_tcp_simult_connect __read_mostly;
>
>  int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
>  int sysctl_tcp_abc __read_mostly;
> @@ -5149,10 +5150,12 @@ discard:
>            tcp_paws_check(&tp->rx_opt, 0))
>                goto discard_and_undo;
>
> -       if (th->syn) {
> +       if (th->syn && sysctl_tcp_simult_connect) {
>                /* We see SYN without ACK. It is attempt of
>                 * simultaneous connect with crossed SYNs.
>                 * Particularly, it can be connect to self.
> +                * This feature is disabled by default as it introduces a
> +                * weakness in the protocol. It can be enabled by a sysctl.
>                 */
>                tcp_set_state(sk, TCP_SYN_RECV);
>
> --
> 1.5.3.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



-- 
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/ Found a documentation bug?
http://www.kernel.org/doc/man-pages/reporting_bugs.html
--
To unsubscribe from this list: send the line "unsubscribe linux-api" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
