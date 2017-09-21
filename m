From: Julien Fortin <julien@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 v2] ip: ip_print: if no json obj is initialized
 default fp is stdout
Date: Wed, 20 Sep 2017 18:22:36 -0700
Message-ID: <CAM_1_Kxj-=0vZ_hy8r6g8Gt8CxPQ2+TV0suU9i_bD1DJ-UuEdw@mail.gmail.com>
References: <20170921011645.45555-1-julien@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:56639 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751000AbdIUBW6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 21:22:58 -0400
Received: by mail-io0-f180.google.com with SMTP id m103so7573283iod.13
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 18:22:58 -0700 (PDT)
In-Reply-To: <20170921011645.45555-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

looks like git-mail ate all the traceback lines starting with #, will
re-submit v3

On Wed, Sep 20, 2017 at 6:16 PM, Julien Fortin
<julien@cumulusnetworks.com> wrote:
> From: Julien Fortin <julien@cumulusnetworks.com>
>
> The ip monitor didn't call `new_json_obj` (even for in non json context),
> so the static FILE* _fp variable wasn't initialized, thus raising a
> SIGSEGV in ipaddress.c. This patch should fix this issue for good, new
> paths won't have to call `new_json_obj`.
>
> $ ip -t mon label link
> fmt=3Dfmt@entry=3D0x45460d =E2=80=9C%d: =E2=80=9C, value=3D<optimized out=
>) at ip_print.c:132
> at libnetlink.c:761
>
> Traceback can be seen when running the following command in a new termina=
l.
> $ ip link add dev br0 type bridge
>
> Fixes: 6377572f ("ip: ip_print: add new API to print JSON or regular form=
at output")
> Reported-by: David Ahern <dsa@cumulusnetworks.com>
> Reviewed-by: David Ahern <dsa@cumulusnetworks.com>
> Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
> ---
>  ip/ip_print.c | 21 +++++++++++++--------
>  1 file changed, 13 insertions(+), 8 deletions(-)
>
> diff --git a/ip/ip_print.c b/ip/ip_print.c
> index 4cd6a0bc..7eb4c6da 100644
> --- a/ip/ip_print.c
> +++ b/ip/ip_print.c
> @@ -23,6 +23,11 @@ static FILE *_fp;
>  #define _IS_JSON_CONTEXT(type) ((type & PRINT_JSON || type & PRINT_ANY) =
&& _jw)
>  #define _IS_FP_CONTEXT(type) (!_jw && (type & PRINT_FP || type & PRINT_A=
NY))
>
> +static inline FILE *_get_fp(void)
> +{
> +       return _fp ? _fp : stdout;
> +};
> +
>  void new_json_obj(int json, FILE *fp)
>  {
>         if (json) {
> @@ -91,7 +96,7 @@ void open_json_array(enum output_type type, const char =
*str)
>                         jsonw_name(_jw, str);
>                 jsonw_start_array(_jw);
>         } else if (_IS_FP_CONTEXT(type)) {
> -               fprintf(_fp, "%s", str);
> +               fprintf(_get_fp(), "%s", str);
>         }
>  }
>
> @@ -105,7 +110,7 @@ void close_json_array(enum output_type type, const ch=
ar *str)
>                 jsonw_end_array(_jw);
>                 jsonw_pretty(_jw, true);
>         } else if (_IS_FP_CONTEXT(type)) {
> -               fprintf(_fp, "%s", str);
> +               fprintf(_get_fp(), "%s", str);
>         }
>  }
>
> @@ -126,7 +131,7 @@ void close_json_array(enum output_type type, const ch=
ar *str)
>                         else                                            \
>                                 jsonw_##type_name##_field(_jw, key, value=
); \
>                 } else if (_IS_FP_CONTEXT(t)) {                         \
> -                       color_fprintf(_fp, color, fmt, value);          \
> +                       color_fprintf(_get_fp(), color, fmt, value);    \
>                 }                                                       \
>         }
>  _PRINT_FUNC(int, int);
> @@ -149,7 +154,7 @@ void print_color_string(enum output_type type,
>                 else
>                         jsonw_string_field(_jw, key, value);
>         } else if (_IS_FP_CONTEXT(type)) {
> -               color_fprintf(_fp, color, fmt, value);
> +               color_fprintf(_get_fp(), color, fmt, value);
>         }
>  }
>
> @@ -170,7 +175,7 @@ void print_color_bool(enum output_type type,
>                 else
>                         jsonw_bool(_jw, value);
>         } else if (_IS_FP_CONTEXT(type)) {
> -               color_fprintf(_fp, color, fmt, value ? "true" : "false");
> +               color_fprintf(_get_fp(), color, fmt, value ? "true" : "fa=
lse");
>         }
>  }
>
> @@ -189,7 +194,7 @@ void print_color_0xhex(enum output_type type,
>                 snprintf(b1, sizeof(b1), "%#x", hex);
>                 print_string(PRINT_JSON, key, NULL, b1);
>         } else if (_IS_FP_CONTEXT(type)) {
> -               color_fprintf(_fp, color, fmt, hex);
> +               color_fprintf(_get_fp(), color, fmt, hex);
>         }
>  }
>
> @@ -208,7 +213,7 @@ void print_color_hex(enum output_type type,
>                 else
>                         jsonw_string(_jw, b1);
>         } else if (_IS_FP_CONTEXT(type)) {
> -               color_fprintf(_fp, color, fmt, hex);
> +               color_fprintf(_get_fp(), color, fmt, hex);
>         }
>  }
>
> @@ -228,6 +233,6 @@ void print_color_null(enum output_type type,
>                 else
>                         jsonw_null(_jw);
>         } else if (_IS_FP_CONTEXT(type)) {
> -               color_fprintf(_fp, color, fmt, value);
> +               color_fprintf(_get_fp(), color, fmt, value);
>         }
>  }
> --
> 2.14.1
>
