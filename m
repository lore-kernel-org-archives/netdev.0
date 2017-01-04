From: Shuah Khan <shuah@kernel.org>
Subject: Re: [PATCH v3 net-next 1/2] tools: psock_lib: tighten conditions
 checked in sock_setfilter
Date: Wed, 4 Jan 2017 15:37:01 -0700
Message-ID: <d3e75147-475a-823c-3530-5150dd24a63d@kernel.org>
References: <cover.1483555162.git.sowmini.varadhan@oracle.com>
 <3aa068fa482f7cf5381957e9a3ea58550822d1d1.1483555162.git.sowmini.varadhan@oracle.com>
Reply-To: shuah@kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, willemb@google.com, davem@davemloft.net,
        Shuah Khan <shuah@kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        linux-kselftest@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from resqmta-po-10v.sys.comcast.net ([96.114.154.169]:50180 "EHLO
        resqmta-po-10v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1757862AbdADWkW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 17:40:22 -0500
In-Reply-To: <3aa068fa482f7cf5381957e9a3ea58550822d1d1.1483555162.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2017 11:45 AM, Sowmini Varadhan wrote:
> The bpf_prog used in sock_setfilter() only attempts to check for
> ip pktlen, and verifies that the contents of the 80'th packet in
> the ethernet frame is 'a' or 'b'.  Thus many non-udp packets
> could incorrectly pass through this filter and cause incorrect
> test results.
> 
> This commit hardens the conditions checked by the filter so
> that only UDP/IPv4 packets with the matching length and test-character
> will be permitted by the filter. The filter has been cleaned up
> to explicitly use the BPF macros to make it more readable.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Acked-by: Willem de Bruijn <willemb@google.com>
> ---
> v2: commit comment edited based on Willem de Bruijn review
> v3: Shuah Khan nit.
> 
>  tools/testing/selftests/net/psock_lib.h |   29 ++++++++++++++++++++++-------
>  1 files changed, 22 insertions(+), 7 deletions(-)
> 
> diff --git a/tools/testing/selftests/net/psock_lib.h b/tools/testing/selftests/net/psock_lib.h
> index 24bc7ec..9e5553a 100644
> --- a/tools/testing/selftests/net/psock_lib.h
> +++ b/tools/testing/selftests/net/psock_lib.h
> @@ -27,6 +27,7 @@
>  #include <string.h>
>  #include <arpa/inet.h>
>  #include <unistd.h>
> +#include <netinet/udp.h>
>  
>  #define DATA_LEN			100
>  #define DATA_CHAR			'a'
> @@ -40,14 +41,28 @@
>  
>  static __maybe_unused void sock_setfilter(int fd, int lvl, int optnum)
>  {
> +	uint16_t ip_len = DATA_LEN +
> +			  sizeof(struct iphdr) +
> +			  sizeof(struct udphdr);
> +	/* the filter below checks for all of the following conditions that
> +	 * are based on the contents of create_payload()
> +	 *  ether type 0x800 and
> +	 *  ip proto udp     and
> +	 *  ip len == ip_len and
> +	 *  udp[38] == 'a' or udp[38] == 'b'
> +	 */

Looks like you have to do v4 anyway, please make sure your comment
block is one of the acceptable formats based on coding style:

https://marc.info/?l=linux-crypto-vger&m=146799837129319&w=2

>  	struct sock_filter bpf_filter[] = {
> -		{ 0x80, 0, 0, 0x00000000 },  /* LD  pktlen		      */
> -		{ 0x35, 0, 4, DATA_LEN   },  /* JGE DATA_LEN  [f goto nomatch]*/
> -		{ 0x30, 0, 0, 0x00000050 },  /* LD  ip[80]		      */
> -		{ 0x15, 1, 0, DATA_CHAR  },  /* JEQ DATA_CHAR   [t goto match]*/
> -		{ 0x15, 0, 1, DATA_CHAR_1},  /* JEQ DATA_CHAR_1 [t goto match]*/
> -		{ 0x06, 0, 0, 0x00000060 },  /* RET match	              */
> -		{ 0x06, 0, 0, 0x00000000 },  /* RET no match		      */
> +		BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 12),	/* LD ethertype */
> +		BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, ETH_P_IP, 0, 8),
> +		BPF_STMT(BPF_LD|BPF_B|BPF_ABS, 23),	/* LD ip_proto */
> +		BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, IPPROTO_UDP, 0, 6),
> +		BPF_STMT(BPF_LD|BPF_H|BPF_ABS, 16),	/* LD ip_len */
> +		BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, ip_len, 0, 4),
> +		BPF_STMT(BPF_LD|BPF_B|BPF_ABS, 80),	/* LD udp[38] */
> +		BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, DATA_CHAR, 1, 0),
> +		BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, DATA_CHAR_1, 0, 1),
> +		BPF_STMT(BPF_RET | BPF_K, ~0),		/* match */
> +		BPF_STMT(BPF_RET | BPF_K, 0)		/* no match */
>  	};
>  	struct sock_fprog bpf_prog;
>  
> 
