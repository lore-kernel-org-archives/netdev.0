From: Julien Fortin <julien@cumulusnetworks.com>
Subject: Re: [iproute PATCH v2] ipaddress: Fix segfault in 'addr showdump'
Date: Thu, 14 Sep 2017 20:05:10 -0700
Message-ID: <CAM_1_Ky97LTjdEgKUbDQxajskYe_YXqYhJyrLSomsq_uFuVdeQ@mail.gmail.com>
References: <20170913092034.7002-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:47749 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751698AbdIODFc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 23:05:32 -0400
Received: by mail-io0-f174.google.com with SMTP id e189so5350555ioa.4
        for <netdev@vger.kernel.org>; Thu, 14 Sep 2017 20:05:31 -0700 (PDT)
In-Reply-To: <20170913092034.7002-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2 looks good to me, thanks for catching this segfault.

On Wed, Sep 13, 2017 at 2:20 AM, Phil Sutter <phil@nwl.cc> wrote:
> Obviously, 'addr showdump' feature wasn't adjusted to json output
> support. As a consequence, calls to print_string() in print_addrinfo()
> tried to dereference a NULL FILE pointer.
>
> Cc: Julien Fortin <julien@cumulusnetworks.com>
> Fixes: d0e720111aad2 ("ip: ipaddress.c: add support for json output")
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Acked-by: Julien Fortin <julien@cumulusnetworks.com>

> --
> Changes since v1:
> Align json output with that of 'ip -j addr show':
> - Interface index label is 'ifindex', not 'index' and it doesn't belong
>   to 'addr_info' array.
> - Create one 'addr_info' array per dumped address, not one for all.
> ---
>  ip/ipaddress.c | 20 ++++++++++++++++++--
>  1 file changed, 18 insertions(+), 2 deletions(-)
>
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index 9797145023966..4c47809570410 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -1801,17 +1801,33 @@ static int show_handler(const struct sockaddr_nl *nl,
>  {
>         struct ifaddrmsg *ifa = NLMSG_DATA(n);
>
> -       printf("if%d:\n", ifa->ifa_index);
> +       open_json_object(NULL);
> +       print_int(PRINT_ANY, "ifindex", "if%d:\n", ifa->ifa_index);
> +
> +       open_json_array(PRINT_JSON, "addr_info");
> +       open_json_object(NULL);
> +
>         print_addrinfo(NULL, n, stdout);
> +
> +       close_json_object();
> +       close_json_array(PRINT_JSON, NULL);
> +
> +       close_json_object();
>         return 0;
>  }
>
>  static int ipaddr_showdump(void)
>  {
> +       int err;
> +
>         if (ipadd_dump_check_magic())
>                 exit(-1);
>
> -       exit(rtnl_from_file(stdin, &show_handler, NULL));
> +       new_json_obj(json, stdout);
> +       err = rtnl_from_file(stdin, &show_handler, NULL);
> +       delete_json_obj();
> +
> +       exit(err);
>  }
>
>  static int restore_handler(const struct sockaddr_nl *nl,
> --
> 2.13.1
>
