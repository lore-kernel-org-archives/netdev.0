From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v2 3/3] tools: bpftool: add documentation
Date: Mon, 2 Oct 2017 17:55:02 -0700
Message-ID: <20171003005500.yh2gbnofm5ckn54x@ast-mbp>
References: <20171002231130.12406-1-jakub.kicinski@netronome.com>
 <20171002231130.12406-4-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        oss-drivers@netronome.com,
        David Beckett <david.beckett@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36036 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750846AbdJCAzG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 20:55:06 -0400
Received: by mail-pg0-f65.google.com with SMTP id 124so3087480pgi.3
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 17:55:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171002231130.12406-4-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 02, 2017 at 04:11:30PM -0700, Jakub Kicinski wrote:
> Add documentation for bpftool.  Separate files for each subcommand.
> Use rst format.  Documentation is compiled into man pages using
> rst2man.
> 
> Signed-off-by: David Beckett <david.beckett@netronome.com>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
>  tools/bpf/bpftool/Documentation/Makefile         |  34 +++++++
>  tools/bpf/bpftool/Documentation/bpftool-map.txt  | 110 +++++++++++++++++++++++
>  tools/bpf/bpftool/Documentation/bpftool-prog.txt |  81 +++++++++++++++++
>  tools/bpf/bpftool/Documentation/bpftool.txt      |  34 +++++++
>  tools/bpf/bpftool/Makefile                       |   6 ++
>  5 files changed, 265 insertions(+)
>  create mode 100644 tools/bpf/bpftool/Documentation/Makefile
>  create mode 100644 tools/bpf/bpftool/Documentation/bpftool-map.txt
>  create mode 100644 tools/bpf/bpftool/Documentation/bpftool-prog.txt
>  create mode 100644 tools/bpf/bpftool/Documentation/bpftool.txt
> 
> diff --git a/tools/bpf/bpftool/Documentation/Makefile b/tools/bpf/bpftool/Documentation/Makefile
> new file mode 100644
> index 000000000000..ebd21ab2c6df
> --- /dev/null
> +++ b/tools/bpf/bpftool/Documentation/Makefile
> @@ -0,0 +1,34 @@
> +include ../../../scripts/Makefile.include
> +include ../../../scripts/utilities.mak
> +
> +INSTALL ?= install
> +RM ?= rm -f
> +
> +# Make the path relative to DESTDIR, not prefix
> +ifndef DESTDIR
> +prefix?=$(HOME)
> +endif
> +mandir ?= $(prefix)/share/man
> +man8dir = $(mandir)/man8
> +
> +MAN8_TXT = $(wildcard *.txt)
> +
> +_DOC_MAN8 = $(patsubst %.txt,%.8,$(MAN8_TXT))
> +DOC_MAN8 = $(addprefix $(OUTPUT),$(_DOC_MAN8))
> +
> +man: man8
> +man8: $(DOC_MAN8)
> +
> +$(OUTPUT)%.8: %.txt
> +	rst2man $< > $@
> +
> +clean:
> +	$(call QUIET_CLEAN, Documentation) $(RM) $(DOC_MAN8)
> +
> +install: man
> +	$(call QUIET_INSTALL, Documentation-man) \
> +		$(INSTALL) -d -m 755 $(DESTDIR)$(man8dir); \
> +		$(INSTALL) -m 644 $(DOC_MAN8) $(DESTDIR)$(man8dir);
> +
> +.PHONY: man man8 clean install
> +.DEFAULT_GOAL := man
> diff --git a/tools/bpf/bpftool/Documentation/bpftool-map.txt b/tools/bpf/bpftool/Documentation/bpftool-map.txt
> new file mode 100644
> index 000000000000..ea82b9059a0a
> --- /dev/null
> +++ b/tools/bpf/bpftool/Documentation/bpftool-map.txt
> @@ -0,0 +1,110 @@
> +================
> +bpftool-map
> +================
> +-------------------------------------------------------------------------------
> +tool for inspection and simple manipulation of eBPF maps
> +-------------------------------------------------------------------------------
> +
> +:Manual section: 8
> +
> +SYNOPSIS
> +========
> +
> +	**bpftool** **map** *COMMAND*
> +
> +	*COMMANDS* :=
> +	{ show | dump | update | lookup | getnext | delete | pin | help }
> +
> +MAP COMMANDS
> +=============
> +
> +|	**bpftool** map show   [*MAP*]
> +|	**bpftool** map dump    *MAP*
> +|	**bpftool** map update  *MAP*  key *BYTES*   value *VALUE* [*UPDATE_FLAGS*]
> +|	**bpftool** map lookup  *MAP*  key *BYTES*
> +|	**bpftool** map getnext *MAP* [key *BYTES*]
> +|	**bpftool** map delete  *MAP*  key *BYTES*
> +|	**bpftool** map pin     *MAP*  *FILE*
> +|	**bpftool** map help
> +|
> +|	*MAP* := { id MAP_ID | pinned FILE }
> +|	*VALUE* := { BYTES | MAP | PROGRAM }
> +|	*UPDATE_FLAGS* := { any | exist | noexist }
> +
> +DESCRIPTION
> +===========
> +	**bpftool map show**   [*MAP*]
> +		  Show information about loaded maps.  If *MAP* is specified
> +		  show information only about given map, otherwise list all
> +		  maps currently loaded on the system.
> +
> +		  Output will start with map ID followed by map type and
> +		  zero or more named attributes (depending on kernel version).
> +
> +	**bpftool map dump**    *MAP*
> +		  Dump all entries in a given *MAP*.
> +
> +	**bpftool map update**  *MAP*  **key** *BYTES*   **value** *VALUE* [*UPDATE_FLAGS*]
> +		  Update map entry for a given *KEY*.
> +
> +		  *UPDATE_FLAGS* can be one of: **any** update existing entry
> +		  or add if doesn't exit; **exist** update only if entry already
> +		  exists; **noexist** update only if entry doesn't exist.
> +
> +	**bpftool map lookup**  *MAP*  **key** *BYTES*
> +		  Lookup **key** in the map.
> +
> +	**bpftool map getnext** *MAP* [**key** *BYTES*]
> +		  Get next key.  If *key* is not specified, get first key.
> +
> +	**bpftool map delete**  *MAP*  **key** *BYTES*
> +		  Remove entry from the map.
> +
> +	**bpftool map pin**     *MAP*  *FILE*
> +		  Pin map *MAP* as *FILE*.
> +
> +		  Note: *FILE* must be located in *bpffs* mount.
> +
> +	**bpftool map help**
> +		  Print short help message.
> +
> +EXAMPLES
> +========
> +**# bpftool map show**
> +::
> +
> +  10: hash  name:some_map  flags:0x0
> +	key:4B  value:8B  max_entries:2048  memlock:167936B
> +
> +**# bpftool map update id 10 key 13 00 07 00 value 02 00 00 00 01 02 03 04**
> +
> +**# bpftool map lookup id 10 key 0 1 2 3**
> +
> +::
> +
> +  key: 00 01 02 03 value: 00 01 02 03 04 05 06 07
> +
> +
> +**# bpftool map dump id 10**
> +::
> +
> +  key: 00 01 02 03  value: 00 01 02 03 04 05 06 07
> +  key: 0d 00 07 00  value: 02 00 00 00 01 02 03 04
> +  Found 2 elements
> +
> +**# bpftool map getnext id 10 key 0 1 2 3**
> +::
> +
> +  key:
> +  00 01 02 03
> +  next key:
> +  0d 00 07 00
> +
> +|  
> +| **# mount -t bpf none /sys/fs/bpf/**
> +| **# bpftool map pin id 10 /sys/fs/bpf/map**
> +| **# bpftool map del pinned /sys/fs/bpf/map key 13 00 07 00**
> +
> +SEE ALSO
> +========
> +	**bpftool**\ (8), **bpftool-prog**\ (8)
> diff --git a/tools/bpf/bpftool/Documentation/bpftool-prog.txt b/tools/bpf/bpftool/Documentation/bpftool-prog.txt
> new file mode 100644
> index 000000000000..d632de0e0212
> --- /dev/null
> +++ b/tools/bpf/bpftool/Documentation/bpftool-prog.txt
> @@ -0,0 +1,81 @@
> +================
> +bpftool-prog
> +================
> +-------------------------------------------------------------------------------
> +tool for inspection and simple manipulation of eBPF progs
> +-------------------------------------------------------------------------------
> +
> +:Manual section: 8
> +
> +SYNOPSIS
> +========
> +
> +|	**bpftool** prog show [*PROG*]
> +|	**bpftool** prog dump xlated *PROG*  file *FILE*
> +|	**bpftool** prog dump jited  *PROG* [file *FILE*] [opcodes]
> +|	**bpftool** prog pin *PROG* *FILE*
> +|	**bpftool** prog help
> +|
> +|	*PROG* := { id *PROG_ID* | pinned *FILE* | tag *PROG_TAG* }
> +
> +DESCRIPTION
> +===========
> +	**bpftool prog show** [*PROG*]
> +		  Show information about loaded programs.  If *PROG* is
> +		  specified show information only about given program, otherwise
> +		  list all programs currently loaded on the system.
> +
> +		  Output will start with program ID followed by program type and
> +		  zero or more named attributes (depending on kernel version).
> +
> +	**bpftool prog dump xlated** *PROG*  **file** *FILE*
> +		  Dump eBPF instructions of the program from the kernel to a
> +		  file.
> +
> +	**bpftool prog dump jited**  *PROG* [**file** *FILE*] [**opcodes**]
> +		  Dump jited image (host machine code) of the program.
> +		  If *FILE* is specified image will be written to a file,
> +		  otherwise it will be disassembled and printed to stdout.
> +
> +		  **opcodes** controls if raw opcodes will be printed.
> +
> +	**bpftool prog pin** *PROG* *FILE*
> +		  Pin program *PROG* as *FILE*.
> +
> +		  Note: *FILE* must be located in *bpffs* mount.
> +
> +	**bpftool prog help**
> +		  Print short help message.
> +
> +EXAMPLES
> +========
> +**# bpftool prog show**
> +::
> +
> +  10: xdp  name:some_prog  tag 00:5a:3d:21:23:62:0c:8b

could you please remove ':' in the output to match what
show_fdinfo and kallsyms do ?

> +	loaded_at:2024.771  uid:0

may be translate that to something human readable?

> +	xlated:528B  jited:370B  memlock:4096B  map_ids:10
> +
> +| 
> +| **# bpftool prog dump xlated id 10 file /tmp/t**
> +| **# ls -l /tmp/t**
> +|   -rw------- 1 root root 560 Jul 22 01:42 /tmp/t
> +
> +| 
> +| **# mount -t bpf none /sys/fs/bpf/**
> +| **# bpftool prog pin id 10 /sys/fs/bpf/prog**
> +| **# bpftool prog dum jited pinned /sys/fs/bpf/prog**
> +
> +::
> +
> +    push   %rbp
> +    mov    %rsp,%rbp
> +    sub    $0x228,%rsp
> +    sub    $0x28,%rbp
> +    mov    %rbx,0x0(%rbp)

imo too many steps to dump disasm output.
Can it print it if we just say:
bpftool prog dump jited id 10
and
dump xlated
will pretty print them as verifier output as well?

All that can be changed later. Thanks for the doc.
Acked-by: Alexei Starovoitov <ast@kernel.org>
