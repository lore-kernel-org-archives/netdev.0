From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v2 1/7] nstat: Avoid passing negative fd to
 fdopen()
Date: Mon, 21 Aug 2017 17:23:23 -0700
Message-ID: <20170821172323.47c335f3@xeon-e3>
References: <20170821170813.29697-1-phil@nwl.cc>
        <20170821170813.29697-2-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:37245 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753979AbdHVAXa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 20:23:30 -0400
Received: by mail-pg0-f53.google.com with SMTP id y129so108505812pgy.4
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 17:23:30 -0700 (PDT)
In-Reply-To: <20170821170813.29697-2-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Aug 2017 19:08:07 +0200
Phil Sutter <phil@nwl.cc> wrote:

> Introduce a wrapper which does the sanity checking and returns NULL
> in case fd is invalid.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  misc/nstat.c | 15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)
> 
> diff --git a/misc/nstat.c b/misc/nstat.c
> index 1212b1f2c8128..7cdde75a56e4e 100644
> --- a/misc/nstat.c
> +++ b/misc/nstat.c
> @@ -252,9 +252,16 @@ static void load_ugly_table(FILE *fp)
>  	}
>  }
>  
> +static FILE *fdopen_null(int fd, const char *mode)
> +{
> +	if (fd < 0)
> +		return NULL;
> +	return fdopen(fd, mode);
> +}
> +
>  static void load_sctp_snmp(void)
>  {
> -	FILE *fp = fdopen(net_sctp_snmp_open(), "r");
> +	FILE *fp = fdopen_null(net_sctp_snmp_open(), "r");
>  
>  	if (fp) {
>  		load_good_table(fp);
> @@ -264,7 +271,7 @@ static void load_sctp_snmp(void)
>  
>  static void load_snmp(void)
>  {
> -	FILE *fp = fdopen(net_snmp_open(), "r");
> +	FILE *fp = fdopen_null(net_snmp_open(), "r");
>  
>  	if (fp) {
>  		load_ugly_table(fp);
> @@ -274,7 +281,7 @@ static void load_snmp(void)
>  
>  static void load_snmp6(void)
>  {
> -	FILE *fp = fdopen(net_snmp6_open(), "r");
> +	FILE *fp = fdopen_null(net_snmp6_open(), "r");
>  
>  	if (fp) {
>  		load_good_table(fp);
> @@ -284,7 +291,7 @@ static void load_snmp6(void)
>  
>  static void load_netstat(void)
>  {
> -	FILE *fp = fdopen(net_netstat_open(), "r");
> +	FILE *fp = fdopen_null(net_netstat_open(), "r");
>  
>  	if (fp) {
>  		load_ugly_table(fp);

Why not just fix it at the source of the open.
I.e 
static FILE *generic_proc_open(condt char * env, const char *name)
{
...
	return fopen(p, "r");
}
