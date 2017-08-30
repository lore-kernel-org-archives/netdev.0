From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [iproute PATCH] lib/bpf: Fix bytecode-file parsing
Date: Wed, 30 Aug 2017 15:53:59 +0200
Message-ID: <59A6C377.90705@iogearbox.net>
References: <20170829150945.7077-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54968 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751330AbdH3NyP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 09:54:15 -0400
In-Reply-To: <20170829150945.7077-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/2017 05:09 PM, Phil Sutter wrote:
> The signedness of char type is implementation dependent, and there are
> architectures on which it is unsigned by default. In that case, the
> check whether fgetc() returned EOF failed because the return value was
> assigned an (unsigned) char variable prior to comparison with EOF (which
> is defined to -1). Fix this by using int as type for 'c' variable, which
> also matches the declaration of fgetc().
>
> While being at it, fix the parser logic to correctly handle multiple
> empty lines and consecutive whitespace and tab characters to further
> improve the parser's robustness. Note that this will still detect double
> separator characters, so doesn't soften up the parser too much.
>
> Fixes: 3da3ebfca85b8 ("bpf: Make bytecode-file reading a little more robust")
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Definitely ack on the EOF bug:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

[...]
> @@ -228,18 +229,20 @@ static int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
>   			case '\n':
>   				if (c_prev != ',')
>   					*(pos++) = ',';
> +				c_prev = ',';
>   				break;
>   			case ' ':
>   			case '\t':
>   				if (c_prev != ' ')
>   					*(pos++) = c;
> +				c_prev = ' ';
>   				break;
>   			default:
>   				*(pos++) = c;
> +				c_prev = c;
>   			}
>   			if (pos - tmp_string == tmp_len)
>   				break;
> -			c_prev = c;

I don't really have a strong opinion on this, but the logic for
normalizing here is getting a bit convoluted. Is your use case
for making the parser more robust mainly so you can just use the
-ddd output from tcpdump for cBPF w/o piping through tr? But even
that shouldn't give multiple empty lines afaik, no?
