From: Quentin Monnet <quentin.monnet@netronome.com>
Subject: Re: [PATCH net-next 3/3] tools: bpftool: optionally show filenames of
 pinned objects
Date: Tue, 31 Oct 2017 11:54:20 +0000
Message-ID: <6bf809f2-acb5-4615-bb63-24325b967d12@netronome.com>
References: <20171031073632.8140-1-bhole_prashant_q7@lab.ntt.co.jp>
 <20171031073632.8140-4-bhole_prashant_q7@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:45844 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751565AbdJaLyX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 07:54:23 -0400
Received: by mail-wm0-f65.google.com with SMTP id y80so15096707wmd.0
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 04:54:22 -0700 (PDT)
In-Reply-To: <20171031073632.8140-4-bhole_prashant_q7@lab.ntt.co.jp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-10-31 16:36 UTC+0900 ~ Prashant Bhole <bhole_prashant_q7@lab.ntt.co.=
jp>
> Making it optional to show file names of pinned objects because
> it scans complete bpf-fs filesystem which is costly.
> Added option -l|--pinned
>
> Signed-off-by: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>
> ---
>  tools/bpf/bpftool/main.c | 14 +++++++++++---
>  tools/bpf/bpftool/main.h |  3 ++-
>  tools/bpf/bpftool/map.c  |  3 ++-
>  tools/bpf/bpftool/prog.c |  3 ++-
>  4 files changed, 17 insertions(+), 6 deletions(-)
>
> diff --git a/tools/bpf/bpftool/main.c b/tools/bpf/bpftool/main.c
> index 6ad53f1..2ae26c6 100644
> --- a/tools/bpf/bpftool/main.c
> +++ b/tools/bpf/bpftool/main.c
> @@ -54,6 +54,7 @@
>  json_writer_t *json_wtr;
>  bool pretty_output;
>  bool json_output;
> +bool show_pinned;
>  struct pinned_obj_table prog_table;
>  struct pinned_obj_table map_table;
> =20
> @@ -265,6 +266,7 @@ int main(int argc, char **argv)
>  		{ "help",	no_argument,	NULL,	'h' },
>  		{ "pretty",	no_argument,	NULL,	'p' },
>  		{ "version",	no_argument,	NULL,	'V' },
> +		{ "pinned",	no_argument,	NULL,	'l' },

=E2=80=9Cl=E2=80=9D is not especially easy to remember for =E2=80=9Cpinne=
d=E2=80=9D, but I don't see a
good alternative, so fine by me (uppercase =E2=80=9CP=E2=80=9D may not ma=
ke things any
better I suppose).

>  		{ 0 }
>  	};
>  	int opt, ret;
> @@ -272,12 +274,13 @@ int main(int argc, char **argv)
>  	last_do_help =3D do_help;
>  	pretty_output =3D false;
>  	json_output =3D false;
> +	show_pinned =3D false;
>  	bin_name =3D argv[0];
> =20
>  	hash_init(prog_table.table);
>  	hash_init(map_table.table);
> =20
> -	while ((opt =3D getopt_long(argc, argv, "Vhpj",
> +	while ((opt =3D getopt_long(argc, argv, "Vhpjl",
>  				  options, NULL)) >=3D 0) {
>  		switch (opt) {
>  		case 'V':
> @@ -290,6 +293,9 @@ int main(int argc, char **argv)
>  		case 'j':
>  			json_output =3D true;
>  			break;
> +		case 'l':
> +			show_pinned =3D true;
> +			break;
>  		default:
>  			usage();
>  		}
> @@ -316,8 +322,10 @@ int main(int argc, char **argv)
>  	if (json_output)
>  		jsonw_destroy(&json_wtr);
> =20
> -	delete_pinned_obj_table(&prog_table);
> -	delete_pinned_obj_table(&map_table);
> +	if (show_pinned) {
> +		delete_pinned_obj_table(&prog_table);
> +		delete_pinned_obj_table(&map_table);
> +	}
> =20
>  	return ret;
>  }
> diff --git a/tools/bpf/bpftool/main.h b/tools/bpf/bpftool/main.h
> index 3abaa17..6c668a6 100644
> --- a/tools/bpf/bpftool/main.h
> +++ b/tools/bpf/bpftool/main.h
> @@ -59,7 +59,7 @@
>  #define HELP_SPEC_PROGRAM						\
>  	"PROG :=3D { id PROG_ID | pinned FILE | tag PROG_TAG }"
>  #define HELP_SPEC_OPTIONS						\
> -	"OPTIONS :=3D { {-j|--json} [{-p|--pretty}] }"
> +	"OPTIONS :=3D { {-j|--json} [{-p|--pretty}] {-l |--pinned} }"

Please add a vertical bar as separator between options, and remove space
after -l:
OPTIONS :=3D { {-j|--json} [{-p|--pretty}] | {-l|--pinned} }

(There is no separator between --json and --pretty because --pretty is
supposed to be used in addition to --json.)

> =20
>  enum bpf_obj_type {
>  	BPF_OBJ_UNKNOWN,
> @@ -71,6 +71,7 @@ enum bpf_obj_type {
> =20
>  extern json_writer_t *json_wtr;
>  extern bool json_output;
> +extern bool show_pinned;
>  extern struct pinned_obj_table prog_table;
>  extern struct pinned_obj_table map_table;
> =20
> diff --git a/tools/bpf/bpftool/map.c b/tools/bpf/bpftool/map.c
> index fbe236e..c4354f8 100644
> --- a/tools/bpf/bpftool/map.c
> +++ b/tools/bpf/bpftool/map.c
> @@ -496,7 +496,8 @@ static int do_show(int argc, char **argv)
>  	int err;
>  	int fd;
> =20
> -	build_pinned_obj_table(&map_table, BPF_OBJ_MAP);
> +	if (show_pinned)
> +		build_pinned_obj_table(&map_table, BPF_OBJ_MAP);
> =20
>  	if (argc =3D=3D 2) {
>  		fd =3D map_parse_fd_and_info(&argc, &argv, &info, &len);
> diff --git a/tools/bpf/bpftool/prog.c b/tools/bpf/bpftool/prog.c
> index cd29eae..c97c954 100644
> --- a/tools/bpf/bpftool/prog.c
> +++ b/tools/bpf/bpftool/prog.c
> @@ -350,7 +350,8 @@ static int do_show(int argc, char **argv)
>  	int err;
>  	int fd;
> =20
> -	build_pinned_obj_table(&prog_table, BPF_OBJ_PROG);
> +	if (show_pinned)
> +		build_pinned_obj_table(&prog_table, BPF_OBJ_PROG);
> =20
>  	if (argc =3D=3D 2) {
>  		fd =3D prog_parse_fd(&argc, &argv);


Please also add documentation for this option in
Documentation/bpftool-prog.rst and Documentation/bpftool-map.rst.

Quentin
