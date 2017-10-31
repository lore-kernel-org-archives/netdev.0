From: Quentin Monnet <quentin.monnet@netronome.com>
Subject: Re: [PATCH net-next 2/3] tools: bpftool: show filenames of pinned
 objects
Date: Tue, 31 Oct 2017 11:41:34 +0000
Message-ID: <40cac52c-36a5-f83f-22d4-2ac2bd90cc34@netronome.com>
References: <20171031073632.8140-1-bhole_prashant_q7@lab.ntt.co.jp>
 <20171031073632.8140-3-bhole_prashant_q7@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:47279 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752572AbdJaLli (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 07:41:38 -0400
Received: by mail-wr0-f195.google.com with SMTP id y39so15647402wrd.4
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 04:41:38 -0700 (PDT)
In-Reply-To: <20171031073632.8140-3-bhole_prashant_q7@lab.ntt.co.jp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-10-31 16:36 UTC+0900 ~ Prashant Bhole <bhole_prashant_q7@lab.ntt.co.=
jp>
> Added support to show filenames of pinned objects.
>
> For example:
>
> root@test# ./bpftool prog
> 3: tracepoint  name tracepoint__irq  tag f677a7dd722299a3
>     loaded_at Oct 26/11:39  uid 0
>     xlated 160B  not jited  memlock 4096B  map_ids 4
>     pinned /sys/fs/bpf/softirq_prog
>
> 4: tracepoint  name tracepoint__irq  tag ea5dc530d00b92b6
>     loaded_at Oct 26/11:39  uid 0
>     xlated 392B  not jited  memlock 4096B  map_ids 4,6
>
> root@test# ./bpftool --json --pretty prog
> [{
>         "id": 3,
>         "type": "tracepoint",
>         "name": "tracepoint__irq",
>         "tag": "f677a7dd722299a3",
>         "loaded_at": "Oct 26/11:39",
>         "uid": 0,
>         "bytes_xlated": 160,
>         "jited": false,
>         "bytes_memlock": 4096,
>         "map_ids": [4
>         ]
> ,
>         "pinned": ["/sys/fs/bpf/softirq_prog"
>         ]
>     },{
>         "id": 4,
>         "type": "tracepoint",
>         "name": "tracepoint__irq",
>         "tag": "ea5dc530d00b92b6",
>         "loaded_at": "Oct 26/11:39",
>         "uid": 0,
>         "bytes_xlated": 392,
>         "jited": false,
>         "bytes_memlock": 4096,
>         "map_ids": [4,6
>         ]
> ,
>         "pinned": []
>     }
> ]
>
> root@test# ./bpftool map
> 4: hash  name start  flags 0x0
>     key 4B  value 16B  max_entries 10240  memlock 1003520B
>     pinned /sys/fs/bpf/softirq_map1
> 5: hash  name iptr  flags 0x0
>     key 4B  value 8B  max_entries 10240  memlock 921600B
>
> root@test# ./bpftool --json --pretty map
> [{
>         "id": 4,
>         "type": "hash",
>         "name": "start",
>         "flags": 0,
>         "bytes_key": 4,
>         "bytes_value": 16,
>         "max_entries": 10240,
>         "bytes_memlock": 1003520,
>         "pinned": ["/sys/fs/bpf/softirq_map1"
>         ]
>     },{
>         "id": 5,
>         "type": "hash",
>         "name": "iptr",
>         "flags": 0,
>         "bytes_key": 4,
>         "bytes_value": 8,
>         "max_entries": 10240,
>         "bytes_memlock": 921600,
>         "pinned": []
>     }
> ]
>
> Signed-off-by: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>
> ---
>  tools/bpf/bpftool/common.c | 70 ++++++++++++++++++++++++++++++++++++++=
++++++++
>  tools/bpf/bpftool/main.c   |  8 ++++++
>  tools/bpf/bpftool/main.h   | 15 ++++++++++
>  tools/bpf/bpftool/map.c    | 22 ++++++++++++++-
>  tools/bpf/bpftool/prog.c   | 23 +++++++++++++++
>  5 files changed, 137 insertions(+), 1 deletion(-)
>
> diff --git a/tools/bpf/bpftool/common.c b/tools/bpf/bpftool/common.c
> index 4556947..6b6247c 100644
> --- a/tools/bpf/bpftool/common.c
> +++ b/tools/bpf/bpftool/common.c
> @@ -45,6 +45,7 @@
>  #include <sys/mount.h>
>  #include <sys/types.h>
>  #include <sys/vfs.h>
> +#include <fts.h>
> =20
>  #include <bpf.h>
> =20
> @@ -290,3 +291,72 @@ void print_hex_data_json(uint8_t *data, size_t len=
)
>  		jsonw_printf(json_wtr, "\"0x%02hhx\"", data[i]);
>  	jsonw_end_array(json_wtr);
>  }
> +
> +int build_pinned_obj_table(struct pinned_obj_table *tab, enum bpf_obj_=
type type)

Nit: line over 80 characters, please wrap.

> +{
> +	char *path[] =3D {"/sys/fs/bpf/", NULL};

This will not work for progs/maps pinned elsewhere on the system. Might
be worth mentioning in the documentation?

> +	FTS *ftsp =3D NULL;
> +	FTSENT *ftse =3D NULL;
> +	enum bpf_obj_type objtype;
> +	struct bpf_prog_info pinned_info =3D {};
> +	__u32 len =3D sizeof(pinned_info);
> +	int fd, err;
> +	struct pinned_obj *obj_node;

Please use reversed-Christmas tree style.

> +
> +	if (!is_bpffs(path[0]))
> +		return -1;
> +
> +	ftsp =3D fts_open(path, 0, NULL);
> +	if (!ftsp)
> +		return -1;
> +
> +	while ((ftse =3D fts_read(ftsp)) !=3D NULL) {
> +		if (!(ftse->fts_info & FTS_F))
> +			continue;
> +		fd =3D open_obj_pinned(ftse->fts_path);
> +		if (fd < 0)
> +			continue;
> +
> +		objtype =3D get_fd_type(fd);
> +		if (objtype !=3D type) {
> +			close(fd);
> +			continue;
> +		}
> +		memset(&pinned_info, 0, sizeof(pinned_info));
> +		err =3D bpf_obj_get_info_by_fd(fd, &pinned_info, &len);
> +		if (err) {
> +			close(fd);
> +			continue;
> +		}
> +
> +		obj_node =3D malloc(sizeof(*obj_node));
> +		if (!obj_node)
> +			return -1;

Maybe fd and ftsp should be closed before returning?

> +
> +		memset(obj_node, 0, sizeof(*obj_node));
> +		obj_node->id =3D pinned_info.id;
> +		obj_node->path =3D strdup(ftse->fts_path);
> +		hash_add(tab->table, &obj_node->hash, obj_node->id);
> +
> +		close(fd);
> +	}
> +
> +	fts_close(ftsp);
> +	return 0;
> +}
> +
> +void delete_pinned_obj_table(struct pinned_obj_table *tab)
> +{
> +	struct pinned_obj *obj;
> +	struct hlist_node *tmp;
> +	unsigned int bkt;
> +
> +	if (hash_empty(tab->table))
> +		return;
> +
> +	hash_for_each_safe(tab->table, bkt, tmp, obj, hash) {
> +		hash_del(&obj->hash);
> +		free(obj->path);
> +		free(obj);
> +	}
> +}
> diff --git a/tools/bpf/bpftool/main.c b/tools/bpf/bpftool/main.c
> index 78d9afb..6ad53f1 100644
> --- a/tools/bpf/bpftool/main.c
> +++ b/tools/bpf/bpftool/main.c
> @@ -54,6 +54,8 @@
>  json_writer_t *json_wtr;
>  bool pretty_output;
>  bool json_output;
> +struct pinned_obj_table prog_table;
> +struct pinned_obj_table map_table;
> =20
>  void usage(void)
>  {
> @@ -272,6 +274,9 @@ int main(int argc, char **argv)
>  	json_output =3D false;
>  	bin_name =3D argv[0];
> =20
> +	hash_init(prog_table.table);
> +	hash_init(map_table.table);
> +
>  	while ((opt =3D getopt_long(argc, argv, "Vhpj",
>  				  options, NULL)) >=3D 0) {
>  		switch (opt) {
> @@ -311,5 +316,8 @@ int main(int argc, char **argv)
>  	if (json_output)
>  		jsonw_destroy(&json_wtr);
> =20
> +	delete_pinned_obj_table(&prog_table);
> +	delete_pinned_obj_table(&map_table);
> +
>  	return ret;
>  }
> diff --git a/tools/bpf/bpftool/main.h b/tools/bpf/bpftool/main.h
> index 4b56850..3abaa17 100644
> --- a/tools/bpf/bpftool/main.h
> +++ b/tools/bpf/bpftool/main.h
> @@ -42,6 +42,7 @@
>  #include <stdio.h>
>  #include <linux/bpf.h>
>  #include <linux/kernel.h>
> +#include <linux/hashtable.h>
> =20
>  #include "json_writer.h"
> =20
> @@ -70,11 +71,25 @@ enum bpf_obj_type {
> =20
>  extern json_writer_t *json_wtr;
>  extern bool json_output;
> +extern struct pinned_obj_table prog_table;
> +extern struct pinned_obj_table map_table;
> =20
>  bool is_prefix(const char *pfx, const char *str);
>  void fprint_hex(FILE *f, void *arg, unsigned int n, const char *sep);
>  void usage(void) __attribute__((noreturn));
> =20
> +struct pinned_obj_table {
> +	DECLARE_HASHTABLE(table, 16);
> +};
> +
> +struct pinned_obj {
> +	__u32 id;
> +	char *path;
> +	struct hlist_node hash;
> +};

Nit: add a blank line here?

> +int build_pinned_obj_table(struct pinned_obj_table *table, enum bpf_ob=
j_type type);

Please wrap this line as well.

> +void delete_pinned_obj_table(struct pinned_obj_table *tab);
> +
>  struct cmd {
>  	const char *cmd;
>  	int (*func)(int argc, char **argv);
> diff --git a/tools/bpf/bpftool/map.c b/tools/bpf/bpftool/map.c
> index e978ab2..fbe236e 100644
> --- a/tools/bpf/bpftool/map.c
> +++ b/tools/bpf/bpftool/map.c
> @@ -436,6 +436,18 @@ static int show_map_close_json(int fd, struct bpf_=
map_info *info)
>  		jsonw_int_field(json_wtr, "bytes_memlock", atoi(memlock));
>  	free(memlock);
> =20
> +	if (!hash_empty(map_table.table)) {
> +		struct pinned_obj *obj;
> +
> +		jsonw_name(json_wtr, "pinned");
> +		jsonw_start_array(json_wtr);
> +		hash_for_each_possible(map_table.table, obj, hash, info->id) {
> +			if (obj->id =3D=3D info->id)
> +				jsonw_string(json_wtr, obj->path);
> +		}
> +		jsonw_end_array(json_wtr);
> +	}
> +
>  	jsonw_end_object(json_wtr);
> =20
>  	return 0;
> @@ -466,7 +478,13 @@ static int show_map_close_plain(int fd, struct bpf=
_map_info *info)
>  	free(memlock);
> =20
>  	printf("\n");
> -
> +	if (!hash_empty(map_table.table)) {
> +		struct pinned_obj *obj;

Nit: add a blank line after declarations.

> +		hash_for_each_possible(map_table.table, obj, hash, info->id) {
> +			if (obj->id =3D=3D info->id)
> +				printf("\tpinned %s\n", obj->path);
> +		}
> +	}
>  	return 0;
>  }
> =20
> @@ -478,6 +496,8 @@ static int do_show(int argc, char **argv)
>  	int err;
>  	int fd;
> =20
> +	build_pinned_obj_table(&map_table, BPF_OBJ_MAP);
> +
>  	if (argc =3D=3D 2) {
>  		fd =3D map_parse_fd_and_info(&argc, &argv, &info, &len);
>  		if (fd < 0)
> diff --git a/tools/bpf/bpftool/prog.c b/tools/bpf/bpftool/prog.c
> index 250f80f..cd29eae 100644
> --- a/tools/bpf/bpftool/prog.c
> +++ b/tools/bpf/bpftool/prog.c
> @@ -207,6 +207,7 @@ static void show_prog_maps(int fd, u32 num_maps)
>  			printf("%u%s", map_ids[i],
>  			       i =3D=3D info.nr_map_ids - 1 ? "" : ",");
>  	}
> +	printf("\n");

This printf() should not be here, because it would add a new line even
if there is no pinned path to add, and regardless of plain / JSON output
selection. It is responsible for the line breaks before the commas you
have in your commit log example.

>  }
> =20
>  static void print_prog_json(struct bpf_prog_info *info, int fd)
> @@ -256,6 +257,18 @@ static void print_prog_json(struct bpf_prog_info *=
info, int fd)
>  	if (info->nr_map_ids)
>  		show_prog_maps(fd, info->nr_map_ids);
> =20
> +	if (!hash_empty(prog_table.table)) {
> +		struct pinned_obj *obj;
> +
> +		jsonw_name(json_wtr, "pinned");
> +		jsonw_start_array(json_wtr);
> +		hash_for_each_possible(prog_table.table, obj, hash, info->id) {
> +			if (obj->id =3D=3D info->id)
> +				jsonw_string(json_wtr, obj->path);
> +		}
> +		jsonw_end_array(json_wtr);
> +	}
> +
>  	jsonw_end_object(json_wtr);
>  }
> =20
> @@ -300,6 +313,14 @@ static void print_prog_plain(struct bpf_prog_info =
*info, int fd)
>  	if (info->nr_map_ids)
>  		show_prog_maps(fd, info->nr_map_ids);
> =20
> +	if (!hash_empty(prog_table.table)) {
> +		struct pinned_obj *obj;

Nit: add a blank line after declarations.
Here might be a better place for the printf("\n");?

> +		hash_for_each_possible(prog_table.table, obj, hash, info->id) {
> +			if (obj->id =3D=3D info->id)
> +				printf("\tpinned %s\n", obj->path);
> +		}
> +	}
> +
>  	printf("\n");
>  }
> =20
> @@ -329,6 +350,8 @@ static int do_show(int argc, char **argv)
>  	int err;
>  	int fd;
> =20
> +	build_pinned_obj_table(&prog_table, BPF_OBJ_PROG);
> +
>  	if (argc =3D=3D 2) {
>  		fd =3D prog_parse_fd(&argc, &argv);
>  		if (fd < 0)

Quentin
