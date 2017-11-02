From: Quentin Monnet <quentin.monnet@netronome.com>
Subject: Re: [PATCH net-next V2 2/3] tools: bpftool: show filenames of pinned
 objects
Date: Thu, 2 Nov 2017 10:48:40 +0000
Message-ID: <687bb1ee-9774-9257-aeb8-40d92b177fce@netronome.com>
References: <20171102075917.2780-1-bhole_prashant_q7@lab.ntt.co.jp>
 <20171102075917.2780-3-bhole_prashant_q7@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:56803 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752237AbdKBKsn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 06:48:43 -0400
Received: by mail-wm0-f66.google.com with SMTP id z3so10346944wme.5
        for <netdev@vger.kernel.org>; Thu, 02 Nov 2017 03:48:43 -0700 (PDT)
In-Reply-To: <20171102075917.2780-3-bhole_prashant_q7@lab.ntt.co.jp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-11-02 16:59 UTC+0900 ~ Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>
> Added support to show filenames of pinned objects.
> 
> For example:
> 

[…]

> 
> Signed-off-by: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>
> ---
> v2:
>  - Dynamically identify bpf-fs moutpoint
>  - Close files descriptors before returning on error
>  - Fixed line break for proper output formatting
>  - Code style: wrapped lines > 80, used reverse christmastree style

Thanks for those changes!

> 
>  tools/bpf/bpftool/common.c | 93 ++++++++++++++++++++++++++++++++++++++++++++++
>  tools/bpf/bpftool/main.c   |  8 ++++
>  tools/bpf/bpftool/main.h   | 17 +++++++++
>  tools/bpf/bpftool/map.c    | 21 +++++++++++
>  tools/bpf/bpftool/prog.c   | 24 ++++++++++++
>  5 files changed, 163 insertions(+)
> 
> diff --git a/tools/bpf/bpftool/common.c b/tools/bpf/bpftool/common.c
> index 4556947709ee..78a16c02c778 100644
> --- a/tools/bpf/bpftool/common.c
> +++ b/tools/bpf/bpftool/common.c
> @@ -45,6 +45,8 @@
>  #include <sys/mount.h>
>  #include <sys/types.h>
>  #include <sys/vfs.h>
> +#include <mntent.h>
> +#include <fts.h>
>  
>  #include <bpf.h>
>  
> @@ -290,3 +292,94 @@ void print_hex_data_json(uint8_t *data, size_t len)
>  		jsonw_printf(json_wtr, "\"0x%02hhx\"", data[i]);
>  	jsonw_end_array(json_wtr);
>  }
> +
> +int build_pinned_obj_table(struct pinned_obj_table *tab,
> +			   enum bpf_obj_type type)
> +{
> +	struct bpf_prog_info pinned_info = {};
> +	__u32 len = sizeof(pinned_info);
> +	struct pinned_obj *obj_node = NULL;
> +	enum bpf_obj_type objtype;
> +	struct mntent *mntent = NULL;
> +	FILE *mntfile = NULL;
> +	char *bpf_dir = NULL;
> +	FTSENT *ftse = NULL;
> +	FTS *ftsp = NULL;
> +	int fd, err;
> +
> +	mntfile = setmntent("/proc/mounts", "r");
> +	if (!mntfile)
> +		return -1;
> +
> +	while ((mntent = getmntent(mntfile)) != NULL) {
> +		if (strncmp(mntent->mnt_type, "bpf", 3) == 0) {
> +			bpf_dir = mntent->mnt_dir;
> +			break;

It works well to find a bpf virtual file system, but it stops after the
first one it finds, although it is possible to have several bpffs on the
system. Since you already have all the logics, could you move the
fts_read() step inside this loop, so as to browse all existing bpffs
instead of just the first one?

> +		}
> +	}
> +	fclose(mntfile);
> +
> +	if (bpf_dir) {
> +		char *path[] = {bpf_dir, 0};
> +
> +		ftsp = fts_open(path, 0, NULL);
> +		if (!ftsp)
> +			return -1;
> +	} else {
> +		return -1;
> +	}
> +
> +

Nitpicking again: this time, you have too many blank lines here :-)

> +	while ((ftse = fts_read(ftsp)) != NULL) {
> +		if (!(ftse->fts_info & FTS_F))
> +			continue;
> +		fd = open_obj_pinned(ftse->fts_path);
> +		if (fd < 0)
> +			continue;
> +
> +		objtype = get_fd_type(fd);
> +		if (objtype != type) {
> +			close(fd);
> +			continue;
> +		}
> +		memset(&pinned_info, 0, sizeof(pinned_info));
> +		err = bpf_obj_get_info_by_fd(fd, &pinned_info, &len);
> +		if (err) {
> +			close(fd);
> +			continue;
> +		}
> +
> +		obj_node = malloc(sizeof(*obj_node));
> +		if (!obj_node) {
> +			close(fd);
> +			fts_close(ftsp);
> +			return -1;
> +		}
> +
> +		memset(obj_node, 0, sizeof(*obj_node));
> +		obj_node->id = pinned_info.id;
> +		obj_node->path = strdup(ftse->fts_path);
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
> index 78d9afb74ef4..6ad53f1797fa 100644
> --- a/tools/bpf/bpftool/main.c
> +++ b/tools/bpf/bpftool/main.c
> @@ -54,6 +54,8 @@ static int (*last_do_help)(int argc, char **argv);
>  json_writer_t *json_wtr;
>  bool pretty_output;
>  bool json_output;
> +struct pinned_obj_table prog_table;
> +struct pinned_obj_table map_table;
>  
>  void usage(void)
>  {
> @@ -272,6 +274,9 @@ int main(int argc, char **argv)
>  	json_output = false;
>  	bin_name = argv[0];
>  
> +	hash_init(prog_table.table);
> +	hash_init(map_table.table);
> +
>  	while ((opt = getopt_long(argc, argv, "Vhpj",
>  				  options, NULL)) >= 0) {
>  		switch (opt) {
> @@ -311,5 +316,8 @@ int main(int argc, char **argv)
>  	if (json_output)
>  		jsonw_destroy(&json_wtr);
>  
> +	delete_pinned_obj_table(&prog_table);
> +	delete_pinned_obj_table(&map_table);
> +
>  	return ret;
>  }
> diff --git a/tools/bpf/bpftool/main.h b/tools/bpf/bpftool/main.h
> index 4b5685005cb0..bd6d0663228b 100644
> --- a/tools/bpf/bpftool/main.h
> +++ b/tools/bpf/bpftool/main.h
> @@ -42,6 +42,7 @@
>  #include <stdio.h>
>  #include <linux/bpf.h>
>  #include <linux/kernel.h>
> +#include <linux/hashtable.h>
>  
>  #include "json_writer.h"
>  
> @@ -70,11 +71,27 @@ extern const char *bin_name;
>  
>  extern json_writer_t *json_wtr;
>  extern bool json_output;
> +extern struct pinned_obj_table prog_table;
> +extern struct pinned_obj_table map_table;
>  
>  bool is_prefix(const char *pfx, const char *str);
>  void fprint_hex(FILE *f, void *arg, unsigned int n, const char *sep);
>  void usage(void) __attribute__((noreturn));
>  
> +struct pinned_obj_table {
> +	DECLARE_HASHTABLE(table, 16);
> +};
> +
> +struct pinned_obj {
> +	__u32 id;
> +	char *path;
> +	struct hlist_node hash;
> +};
> +
> +int build_pinned_obj_table(struct pinned_obj_table *table,
> +						  enum bpf_obj_type type);

Thanks for wrapping, but it does not seem to be aligned correctly.
“enum” should be aligned with “struct” from line above, and tabulations
should be 8-character long.

Quentin
