From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [iproute PATCH 51/51] lib/bpf: Check return value of write()
Date: Tue, 15 Aug 2017 12:31:42 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0055BA8@AcuExch.aculab.com>
References: <20170812120510.28750-1-phil@nwl.cc>
 <20170812120510.28750-52-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Phil Sutter' <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.189]:64923 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751129AbdHOMbs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 08:31:48 -0400
In-Reply-To: <20170812120510.28750-52-phil@nwl.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter
> Sent: 12 August 2017 13:05
> This is merely to silence the compiler warning. If write to stderr
> failed, assume that printing an error message will fail as well so don't
> even try.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  lib/bpf.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/lib/bpf.c b/lib/bpf.c
> index 1dcb261dc915f..825e071cea572 100644
> --- a/lib/bpf.c
> +++ b/lib/bpf.c
> @@ -591,7 +591,8 @@ int bpf_trace_pipe(void)
> 
>  		ret = read(fd, buff, sizeof(buff) - 1);
>  		if (ret > 0) {
> -			write(2, buff, ret);
> +			if (write(STDERR_FILENO, buff, ret) != ret)
> +				return -1;
>  			fflush(stderr);
>  		}

WTF is this code doing anyway?
write() is a system call, fflush() writes out any data buffered in the
stdio stream.
If there was anything buffered you'd want to output it earlier.
Otherwise if it is going to use fflush() it should be using fwrite().

I presume the function is allowed to write to stderr - since in general
library functions shouldn't assume fd 0/1/2 or stdin/out/err are valid.
There is a lot of code out there that does close(0); close(1); close(2);
but leaves stdout/err valid. Call printf() instead of sprint() and eventually
10k of data gets written somewhere rather unexpected.

If it is a copy loop, what is wrong with the last byte of buff[].
It is valid for write() to return a partial length - the code should
probably loop until all the data is accepted (or error).

	David
