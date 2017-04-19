From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH net-next v6 09/11] seccomp: Enhance test_harness with an
 assert step mechanism
Date: Tue, 18 Apr 2017 17:02:57 -0700
Message-ID: <CAGXu5j+D-FP8Kt9unNOqKrQJP4DYTpmgkJxWykZyrYiVPz3Y3Q@mail.gmail.com>
References: <20170328234650.19695-1-mic@digikod.net> <20170328234650.19695-10-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Arnaldo Carvalho de Melo <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        David Drysdale <drysdale-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>,
        Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        "Serge E . Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
        Shuah Khan <shuah-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Will Drewry <wa
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170328234650.19695-10-mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 28, 2017 at 4:46 PM, Micka=C3=ABl Sala=C3=BCn <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>=
 wrote:
> This is useful to return an information about the error without being
> able to write to TH_LOG_STREAM.
>
> Helpers from test_harness.h may be useful outside of the seccomp
> directory.
>
> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
> Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
> Cc: Arnaldo Carvalho de Melo <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> Cc: Shuah Khan <shuah-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> ---
>  tools/testing/selftests/seccomp/test_harness.h | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
>
> diff --git a/tools/testing/selftests/seccomp/test_harness.h b/tools/testi=
ng/selftests/seccomp/test_harness.h
> index a786c69c7584..77e407663e06 100644
> --- a/tools/testing/selftests/seccomp/test_harness.h
> +++ b/tools/testing/selftests/seccomp/test_harness.h
> @@ -397,7 +397,7 @@ struct __test_metadata {
>         const char *name;
>         void (*fn)(struct __test_metadata *);
>         int termsig;
> -       int passed;
> +       __s8 passed;

Why the reduction here? int is signed too?

>         int trigger; /* extra handler after the evaluation */
>         struct __test_metadata *prev, *next;
>  };
> @@ -476,6 +476,12 @@ void __run_test(struct __test_metadata *t)
>                                         "instead of by signal (code: %d)\=
n",
>                                         t->name,
>                                         WEXITSTATUS(status));
> +                       } else if (t->passed < 0) {
> +                               fprintf(TH_LOG_STREAM,
> +                                       "%s: Failed at step #%d\n",
> +                                       t->name,
> +                                       t->passed * -1);
> +                               t->passed =3D 0;
>                         }

Instead of creating an overloaded mechanism here, perhaps have an
option reporting mechanism that can be enabled. Like adding to
__test_metadata "bool no_stream; int test_number;" and adding
test_number++ to each ASSERT/EXCEPT call, and doing something like:

if (t->no_stream) {
                              fprintf(TH_LOG_STREAM,
                                      "%s: Failed at step #%d\n",
                                      t->name,
                                       t->test_number);
}

It'd be a cleaner approach, maybe?

-Kees

--=20
Kees Cook
Pixel Security
