From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH] sockperf: add SO_LL socketop support
Date: Wed, 12 Jun 2013 11:36:54 +0300
Message-ID: <51B83326.4080201@mellanox.com>
References: <20130611142415.17879.75569.stgit@ladj378.jer.intel.com>
	<51B73395.7070706@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Don, Or Kehati <ork@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Eliezer Tamir <eliezer@tamir.org.il>, linux-kernel@vger.kernel.org,
	Avner Ben Hanoch <avnerb@mellanox.com>, Andi Kleen <andi@firstfloor.org>,
	Alex Rosenbaum <Alexr@mellanox.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <erdnetdev@gmail.com>, Eilon Greenstien <eilong@broadcom.com>,
	David Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <51B73395.7070706@linux.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 11/06/2013 17:26, Eliezer Tamir wrote:
> Add lls socket option support to sockperf.
> Right now we always get the option before set to show the option is
> working properly. We should probably remove that in an official release.
> use --lls (value in usecs) to override global setting.
> ---
> 
>  src/Defs.h       |    3 +++
>  src/SockPerf.cpp |   54
> +++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 56 insertions(+), 1 deletions(-)
> 
> diff --git a/src/Defs.h b/src/Defs.h
> index e38e3a4..87b45a0 100644
> --- a/src/Defs.h
> +++ b/src/Defs.h
> @@ -161,6 +161,7 @@ enum {
>      OPT_OUTPUT_PRECISION,           //35
>      OPT_CLIENTPORT,                 //36
>      OPT_CLIENTIP,                   //37
> +    OPT_LLS,            //38
>  };
> 
>  #define MODULE_NAME            "sockperf"
> @@ -527,6 +528,8 @@ struct user_params_t {
>  //    bool stream_mode; - use b_stream instead
>      int mthread_server;
>      struct timeval* select_timeout;
> +    unsigned long lls_usecs;
> +    bool lls_is_set;
>      int sock_buff_size;
>      int threads_num;
>      char threads_affinity[MAX_ARGV_SIZE];
> diff --git a/src/SockPerf.cpp b/src/SockPerf.cpp
> index 41daf95..d76320f 100644
> --- a/src/SockPerf.cpp
> +++ b/src/SockPerf.cpp
> @@ -207,6 +207,10 @@ static const AOPT_DESC  common_opt_desc[] =
>          "Limit the lifetime of the message (default 2)."
>      },
>      {
> +        OPT_LLS, AOPT_ARG, aopt_set_literal( 0 ), aopt_set_string(
> "lls" ),
> +        "Turn on LLS via socket option (value = us to poll)."
> +    },
> +    {
>          OPT_BUFFER_SIZE, AOPT_ARG, aopt_set_literal( 0 ),
> aopt_set_string( "buffer-size" ),
>          "Set total socket receive/send buffer <size> in bytes (system
> defined by default)."
>      },
> @@ -292,7 +296,7 @@ static int proc_mode_help( int id, int argc, const
> char **argv )
>      int   i = 0;
> 
>      printf(MODULE_NAME " is a tool for testing network latency and
> throughput.\n");
> -    printf("version %s\n", STR(VERSION));
> +    printf("version %s-lls\n", STR(VERSION));
>      printf("\n");
>      printf("Usage: " MODULE_NAME " <subcommand> [options] [args]\n");
>      printf("Type: \'" MODULE_NAME " <subcommand> --help\' for help on a
> specific subcommand.\n");
> @@ -1789,6 +1793,26 @@ static int parse_common_opt( const AOPT_OBJECT
> *common_obj )
>              s_user_params.is_nonblocked_send = true;
>          }
> 
> +        if ( !rc && aopt_check(common_obj, OPT_LLS) ) {
> +            const char* optarg = aopt_value(common_obj, OPT_LLS);
> +            if (optarg) {
> +                errno = 0;
> +                int value = strtoul(optarg, NULL, 0);
> +                if (errno != 0 || value < 0) {
> +                    log_msg("'-%d' Invalid LLS value: %s", OPT_LLS,
> optarg);
> +                    rc = SOCKPERF_ERR_BAD_ARGUMENT;
> +                }
> +                else {
> +                    s_user_params.lls_usecs = value;
> +                    s_user_params.lls_is_set = true;
> +                }
> +            }
> +            else {
> +                log_msg("'-%d' Invalid value", OPT_LLS);
> +                rc = SOCKPERF_ERR_BAD_ARGUMENT;
> +            }
> +        }
> +
>          if ( !rc && aopt_check(common_obj, OPT_RECV_LOOPING) ) {
> 
>              const char* optarg = aopt_value(common_obj, OPT_RECV_LOOPING);
> @@ -2296,6 +2320,29 @@ int sock_set_reuseaddr(int fd)
>      return rc;
>  }
> 
> +#ifndef SO_LL
> +#define SO_LL 46
> +#endif
> +int sock_set_lls(int fd)
> +{
> +    int rc = SOCKPERF_ERR_NONE;
> +    unsigned long lls;
> +    int size = sizeof(lls);
> +
> +    if(getsockopt(fd, SOL_SOCKET, SO_LL, &lls, (socklen_t *)&size) < 0){
> +        log_err("getsockopt(SO_LL) failed");
> +        return SOCKPERF_ERR_SOCKET;
> +    } else
> +        log_msg("socket option SO_LL default was %lu, changing to %lu",
> lls, s_user_params.lls_usecs);
> +
> +    if (setsockopt(fd, SOL_SOCKET, SO_LL, &(s_user_params.lls_usecs),
> sizeof(s_user_params.lls_usecs)) < 0) {
> +        log_err("setsockopt(SO_LL) failed");
> +        rc = SOCKPERF_ERR_SOCKET;
> +    }
> +    return rc;
> +}
> +
> +
>  int sock_set_snd_rcv_bufs(int fd)
>  {
>      /*
> @@ -2460,6 +2507,11 @@ int prepare_socket(int fd, struct fds_data *p_data)
>      }
> 
>      if (!rc &&
> +            (s_user_params.lls_is_set == true))
> +    {
> +        rc = sock_set_lls(fd);
> +    }
> +    if (!rc &&
>              (s_user_params.sock_buff_size > 0))
>      {
>          rc = sock_set_snd_rcv_bufs(fd);
> 
> 
> 
> 
> 

Eliezer Hi,

Added sockperf maintainers to CC list.

To upload changes to sockperf code, please open a ticket on the sockperf
google code and then submit the patch
(https://code.google.com/p/sockperf/issues/).

You will need to wrap it in " #ifndef w-i-n-d-o-w-s" but sockperf
maintainers can help you do that on the sockperf pages.

You should look at the recently added TOS which is very similar
(https://code.google.com/p/sockperf/issues/detail?id=44).

Amir

------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
