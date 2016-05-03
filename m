From: Quentin Monnet <quentin.monnet@6wind.com>
Subject: [PATCH iproute2 v2] tc: add bash-completion function
Date: Tue,  3 May 2016 09:39:08 +0200
Message-ID: <1462261148-5448-1-git-send-email-quentin.monnet@6wind.com>
References: <20160502151414.0c9c3e3a@xeon-e3>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	Vincent Jardin <vincent.jardin@6wind.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36088 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846AbcECHj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 03:39:56 -0400
Received: by mail-wm0-f47.google.com with SMTP id n129so134689791wmn.1
        for <netdev@vger.kernel.org>; Tue, 03 May 2016 00:39:55 -0700 (PDT)
In-Reply-To: <20160502151414.0c9c3e3a@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add function for command completion for tc in bash, and update Makefile
to install it under /usr/share/bash-completion/completions/.

Inside iproute2 repository, the completion code is in a new
`bash-completion` toplevel directory.

v2: Remove `if` statement in Makefile: do not try to install in
    /etc/bash_completion.d/ if /usr/share/bash-completion/completions/
    is not found; instead, the user can override the installation path
    with the specific environment variable.

Signed-off-by: Quentin Monnet <quentin.monnet@6wind.com>
---
 Makefile           |   3 +
 bash-completion/tc | 723 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 726 insertions(+)
 create mode 100644 bash-completion/tc

diff --git a/Makefile b/Makefile
index 0190aa004a79..eb571a5accf8 100644
--- a/Makefile
+++ b/Makefile
@@ -7,6 +7,7 @@ DOCDIR?=$(DATADIR)/doc/iproute2
 MANDIR?=$(DATADIR)/man
 ARPDDIR?=/var/lib/arpd
 KERNEL_INCLUDE?=/usr/include
+BASH_COMPDIR?=$(DATADIR)/bash-completion/completions
 
 # Path to db_185.h include
 DBM_INCLUDE:=$(DESTDIR)/usr/include
@@ -66,6 +67,8 @@ install: all
 		$(DESTDIR)$(DOCDIR)/examples/diffserv
 	@for i in $(SUBDIRS) doc; do $(MAKE) -C $$i install; done
 	install -m 0644 $(shell find etc/iproute2 -maxdepth 1 -type f) $(DESTDIR)$(CONFDIR)
+	install -m 0755 -d $(DESTDIR)$(BASH_COMPDIR)
+	install -m 0644 bash-completion/tc $(DESTDIR)$(BASH_COMPDIR)
 
 snapshot:
 	echo "static const char SNAPSHOT[] = \""`date +%y%m%d`"\";" \
diff --git a/bash-completion/tc b/bash-completion/tc
new file mode 100644
index 000000000000..79dd5fcc172c
--- /dev/null
+++ b/bash-completion/tc
@@ -0,0 +1,723 @@
+# tc(8) completion                                         -*- shell-script -*-
+# Copyright 2016 6WIND S.A.
+# Copyright 2016 Quentin Monnet <quentin.monnet@6wind.com>
+
+# Takes a list of words in argument; each one of them is added to COMPREPLY if
+# it is not already present on the command line. Returns no value.
+_tc_once_attr()
+{
+    local w subcword found
+    for w in $*; do
+        found=0
+        for (( subcword=3; subcword < ${#words[@]}-1; subcword++ )); do
+            if [[ $w == ${words[subcword]} ]]; then
+                found=1
+                break
+            fi
+        done
+        [[ $found -eq 0 ]] && \
+            COMPREPLY+=( $( compgen -W "$w" -- "$cur" ) )
+    done
+}
+
+# Takes a list of words in argument; adds them all to COMPREPLY if none of them
+# is already present on the command line. Returns no value.
+_tc_one_of_list()
+{
+    local w subcword
+    for w in $*; do
+        for (( subcword=3; subcword < ${#words[@]}-1; subcword++ )); do
+            [[ $w == ${words[subcword]} ]] && return 1
+        done
+    done
+    COMPREPLY+=( $( compgen -W "$*" -- "$cur" ) )
+}
+
+# Returns "$cur ${cur}arg1 ${cur}arg2 ..."
+_tc_expand_units()
+{
+    [[ $cur =~ ^[0-9]+ ]] || return 1
+    local value=${cur%%[^0-9]*}
+    [[ $cur == $value ]] && echo $cur
+    echo ${@/#/$value}
+}
+
+# Complete based on given word, usually $prev (or possibly the word before),
+# for when an argument or an option name has but a few possible arguments (so
+# tc does not take particular commands into account here).
+# Returns 0 is completion should stop after running this function, 1 otherwise.
+_tc_direct_complete()
+{
+    case $1 in
+        # Command options
+        dev)
+            _available_interfaces
+            return 0
+            ;;
+        classid)
+            return 0
+            ;;
+        estimator)
+            local list=$( _tc_expand_units 'secs' 'msecs' 'usecs' )
+            COMPREPLY+=( $( compgen -W "$list" -- "$cur" ) )
+            return 0
+            ;;
+        handle)
+            return 0
+            ;;
+        parent|flowid)
+            local i iface ids cmd
+            for (( i=3; i < ${#words[@]}-2; i++ )); do
+                [[ ${words[i]} == dev ]] && iface=${words[i+1]}
+                break
+            done
+            for cmd in qdisc class; do
+                if [[ -n $iface ]]; then
+                    ids+=$( tc $cmd show dev $iface 2>/dev/null | \
+                        cut -d\  -f 3 )" "
+                else
+                    ids+=$( tc $cmd show 2>/dev/null | cut -d\  -f 3 )
+                fi
+            done
+            [[ $ids != " " ]] && \
+                COMPREPLY+=( $( compgen -W "$ids" -- "$cur" ) )
+            return 0
+            ;;
+        protocol) # list comes from lib/ll_proto.c
+            COMPREPLY+=( $( compgen -W ' 802.1Q 802.1ad 802_2 802_3 LLDP aarp \
+                all aoe arp atalk atmfate atmmpoa ax25 bpq can control cust \
+                ddcmp dec diag dna_dl dna_rc dna_rt econet ieeepup ieeepupat \
+                ip ipv4 ipv6 ipx irda lat localtalk loop mobitex ppp_disc \
+                ppp_mp ppp_ses ppptalk pup pupat rarp sca snap tipc tr_802_2 \
+                wan_ppp x25' -- "$cur" ) )
+            return 0
+            ;;
+        prio)
+            return 0
+            ;;
+        stab)
+            COMPREPLY+=( $( compgen -W 'mtu tsize mpu overhead
+                linklayer' -- "$cur" ) )
+            ;;
+
+        # Qdiscs and classes options
+        alpha|bands|beta|buckets|corrupt|debug|decrement|default|\
+        default_index|depth|direct_qlen|divisor|duplicate|ewma|flow_limit|\
+        flows|hh_limit|increment|indices|linklayer|non_hh_weight|num_tc|\
+        penalty_burst|penalty_rate|prio|priomap|probability|queues|r2q|\
+        reorder|vq|vqs)
+            return 0
+            ;;
+        setup)
+            COMPREPLY+=( $( compgen -W 'vqs' -- "$cur" ) )
+            return 0
+            ;;
+        hw)
+            COMPREPLY+=( $( compgen -W '1 0' -- "$cur" ) )
+            return 0
+            ;;
+        distribution)
+            COMPREPLY+=( $( compgen -W 'uniform normal pareto
+                paretonormal' -- "$cur" ) )
+            return 0
+            ;;
+        loss)
+            COMPREPLY+=( $( compgen -W 'random state gmodel' -- "$cur" ) )
+            return 0
+            ;;
+
+        # Qdiscs and classes options options
+        gap|gmodel|state)
+            return 0
+            ;;
+
+        # Filters options
+        map)
+            COMPREPLY+=( $( compgen -W 'key' -- "$cur" ) )
+            return 0
+            ;;
+        hash)
+            COMPREPLY+=( $( compgen -W 'keys' -- "$cur" ) )
+            return 0
+            ;;
+        indev)
+            _available_interfaces
+            return 0
+            ;;
+        eth_type)
+            COMPREPLY+=( $( compgen -W 'ipv4 ipv6' -- "$cur" ) )
+            return 0
+            ;;
+        ip_proto)
+            COMPREPLY+=( $( compgen -W 'tcp udp' -- "$cur" ) )
+            return 0
+            ;;
+
+        # Filters options options
+        key|keys)
+            [[ ${words[@]} =~ graft ]] && return 1
+            COMPREPLY+=( $( compgen -W 'src dst proto proto-src proto-dst iif \
+                priority mark nfct nfct-src nfct-dst nfct-proto-src \
+                nfct-proto-dst rt-classid sk-uid sk-gid vlan-tag rxhash' -- \
+                "$cur" ) )
+            return 0
+            ;;
+
+        # BPF options - used for filters, actions, and exec
+        export|bytecode|bytecode-file|object-file)
+            _filedir
+            return 0
+            ;;
+        object-pinned|graft) # Pinned object is probably under /sys/fs/bpf/
+            [[ -n "$cur" ]] && _filedir && return 0
+            COMPREPLY=( $( compgen -G "/sys/fs/bpf/*" -- "$cur" ) ) || _filedir
+            compopt -o nospace
+            return 0
+            ;;
+        section)
+            if (type objdump > /dev/null 2>&1) ; then
+                local fword objfile section_list
+                for (( fword=3; fword < ${#words[@]}-3; fword++ )); do
+                    if [[ ${words[fword]} == object-file ]]; then
+                        objfile=${words[fword+1]}
+                        break
+                    fi
+                done
+                section_list=$( objdump -h $objfile 2>/dev/null | \
+                    sed -n 's/^ *[0-9]\+ \([^ ]*\) *.*/\1/p' )
+                COMPREPLY+=( $( compgen -W "$section_list" -- "$cur" ) )
+            fi
+            return 0
+            ;;
+        import|run)
+            _filedir
+            return 0
+            ;;
+        type)
+            COMPREPLY+=( $( compgen -W 'cls act' -- "$cur" ) )
+            return 0
+            ;;
+
+        # Actions options
+        random)
+            _tc_one_of_list 'netrand determ'
+            return 0
+            ;;
+
+        # Units for option arguments
+        bandwidth|maxrate|peakrate|rate)
+            local list=$( _tc_expand_units 'bit' \
+                'kbit' 'kibit' 'kbps' 'kibps' \
+                'mbit' 'mibit' 'mbps' 'mibps' \
+                'gbit' 'gibit' 'gbps' 'gibps' \
+                'tbit' 'tibit' 'tbps' 'tibps' )
+            COMPREPLY+=( $( compgen -W "$list" -- "$cur" ) )
+            ;;
+        admit_bytes|avpkt|burst|cell|initial_quantum|limit|max|min|mtu|mpu|\
+        overhead|quantum|redflowlist)
+            local list=$( _tc_expand_units \
+                'b' 'kbit' 'k' 'mbit' 'm' 'gbit' 'g' )
+            COMPREPLY+=( $( compgen -W "$list" -- "$cur" ) )
+            ;;
+        db|delay|evict_timeout|interval|latency|perturb|rehash|reset_timeout|\
+        target|tupdate)
+            local list=$( _tc_expand_units 'secs' 'msecs' 'usecs' )
+            COMPREPLY+=( $( compgen -W "$list" -- "$cur" ) )
+            ;;
+    esac
+    return 1
+}
+
+# Complete with options names for qdiscs. Each qdisc has its own set of options
+# and it seems we cannot really parse it from anywhere, so we add it manually
+# in this function.
+# Returns 0 is completion should stop after running this function, 1 otherwise.
+_tc_qdisc_options()
+{
+    case $1 in
+        choke)
+            _tc_once_attr 'limit bandwidth ecn min max burst'
+            return 0
+            ;;
+        codel)
+            _tc_once_attr 'limit target interval'
+            _tc_one_of_list 'ecn noecn'
+            return 0
+            ;;
+        bfifo|pfifo|pfifo_head_drop)
+            _tc_once_attr 'limit'
+            return 0
+            ;;
+        fq)
+            _tc_once_attr 'limit flow_limit quantum initial_quantum maxrate \
+                buckets'
+            _tc_one_of_list 'pacing nopacing'
+            return 0
+            ;;
+        fq_codel)
+            _tc_once_attr 'limit flows target interval quantum'
+            _tc_one_of_list 'ecn noecn'
+            return 0
+            ;;
+        gred)
+            _tc_once_attr 'setup vqs default grio vq prio limit min max avpkt \
+                burst probability bandwidth'
+            return 0
+            ;;
+        hhf)
+            _tc_once_attr 'limit quantum hh_limit reset_timeout admit_bytes \
+                evict_timeout non_hh_weight'
+            return 0
+            ;;
+        mqprio)
+            _tc_once_attr 'num_tc map queues hw'
+            return 0
+            ;;
+        netem)
+            _tc_once_attr 'delay distribution corrupt duplicate loss ecn \
+                reorder rate'
+            return 0
+            ;;
+        pie)
+            _tc_once_attr 'limit target tupdate alpha beta'
+            _tc_one_of_list 'bytemode nobytemode'
+            _tc_one_of_list 'ecn noecn'
+            return 0
+            ;;
+        red)
+            _tc_once_attr 'limit min max avpkt burst adaptive probability \
+                bandwidth ecn harddrop'
+            return 0
+            ;;
+        rr|prio)
+            _tc_once_attr 'bands priomap multiqueue'
+            return 0
+            ;;
+        sfb)
+            _tc_once_attr 'rehash db limit max target increment decrement \
+                penalty_rate penalty_burst'
+            return 0
+            ;;
+        sfq)
+            _tc_once_attr 'limit perturb quantum divisor flows depth headdrop \
+                redflowlimit min max avpkt burst probability ecn harddrop'
+            return 0
+            ;;
+        tbf)
+            _tc_once_attr 'limit burst rate mtu peakrate latency overhead \
+                linklayer'
+            return 0
+            ;;
+        cbq)
+            _tc_once_attr 'bandwidth avpkt mpu cell ewma'
+            return 0
+            ;;
+        dsmark)
+            _tc_once_attr 'indices default_index set_tc_index'
+            return 0
+            ;;
+        hfsc)
+            _tc_once_attr 'default'
+            return 0
+            ;;
+        htb)
+            _tc_once_attr 'default r2q direct_qlen debug'
+            return 0
+            ;;
+        multiq|pfifo_fast|atm|drr|qfq)
+            return 0
+            ;;
+    esac
+    return 1
+}
+
+# Complete with options names for BPF filters or actions.
+# Returns 0 is completion should stop after running this function, 1 otherwise.
+_tc_bpf_options()
+{
+    [[ ${words[${#words[@]}-3]} == object-file ]] && \
+        _tc_once_attr 'section export'
+    [[ ${words[${#words[@]}-5]} == object-file ]] && \
+        [[ ${words[${#words[@]}-3]} =~ (section|export) ]] && \
+        _tc_once_attr 'section export'
+    _tc_one_of_list 'bytecode bytecode-file object-file object-pinned'
+    _tc_once_attr 'verbose index direct-action action classid'
+    return 0
+}
+
+# Complete with options names for filters.
+# Returns 0 is completion should stop after running this function, 1 otherwise.
+_tc_filter_options()
+{
+    case $1 in
+        basic)
+            _tc_once_attr 'match action classid'
+            return 0
+            ;;
+        bpf)
+            _tc_bpf_options
+            return 0
+            ;;
+        cgroup)
+            _tc_once_attr 'match action'
+            return 0
+            ;;
+        flow)
+            local i
+            for (( i=5; i < ${#words[@]}-1; i++ )); do
+                if [[ ${words[i]} =~ ^keys?$ ]]; then
+                    _tc_direct_complete 'key'
+                    COMPREPLY+=( $( compgen -W 'or and xor rshift addend' -- \
+                        "$cur" ) )
+                    break
+                fi
+            done
+            _tc_once_attr 'map hash divisor baseclass match action'
+            return 0
+            ;;
+        flower)
+            _tc_once_attr 'action classid indev dst_mac src_mac eth_type \
+                ip_proto dst_ip src_ip dst_port src_port'
+            return 0
+            ;;
+        fw)
+            _tc_once_attr 'action classid'
+            return 0
+            ;;
+        route)
+            _tc_one_of_list 'from fromif'
+            _tc_once_attr 'to classid action'
+            return 0
+            ;;
+        rsvp)
+            _tc_once_attr 'ipproto session sender classid action tunnelid \
+                tunnel flowlabel spi/ah spi/esp u8 u16 u32'
+            [[ ${words[${#words[@]}-3]} == tunnel ]] && \
+                    COMPREPLY+=( $( compgen -W 'skip' -- "$cur" ) )
+            [[ ${words[${#words[@]}-3]} =~ u(8|16|32) ]] && \
+                    COMPREPLY+=( $( compgen -W 'mask' -- "$cur" ) )
+            [[ ${words[${#words[@]}-3]} == mask ]] && \
+                    COMPREPLY+=( $( compgen -W 'at' -- "$cur" ) )
+            return 0
+            ;;
+        tcindex)
+            _tc_once_attr 'hash mask shift classid action'
+            _tc_one_of_list 'pass_on fall_through'
+            return 0
+            ;;
+        u32)
+            _tc_once_attr 'match link classid action offset ht hashkey sample'
+            COMPREPLY+=( $( compgen -W 'ip ip6 udp tcp icmp u8 u16 u32 mark \
+                divisor' -- "$cur" ) )
+            return 0
+            ;;
+    esac
+    return 1
+}
+
+# Complete with options names for actions.
+# Returns 0 is completion should stop after running this function, 1 otherwise.
+_tc_action_options()
+{
+    case $1 in
+        bpf)
+            _tc_bpf_options
+            return 0
+            ;;
+        mirred)
+            _tc_one_of_list 'ingress egress'
+            _tc_one_of_list 'mirror redirect'
+            _tc_once_attr 'index dev'
+            return 0
+            ;;
+        gact)
+            _tc_one_of_list 'reclassify drop continue pass'
+            _tc_once_attr 'random'
+            return 0
+            ;;
+    esac
+    return 1
+}
+
+# Complete with options names for exec.
+# Returns 0 is completion should stop after running this function, 1 otherwise.
+_tc_exec_options()
+{
+    case $1 in
+        import)
+            [[ ${words[${#words[@]}-3]} == import ]] && \
+                _tc_once_attr 'run'
+            return 0
+            ;;
+        graft)
+            COMPREPLY+=( $( compgen -W 'key type' -- "$cur" ) )
+            [[ ${words[${#words[@]}-3]} == object-file ]] && \
+                _tc_once_attr 'type'
+            _tc_bpf_options
+            return 0
+            ;;
+    esac
+    return 1
+}
+
+# Main completion function
+# Logic is as follows:
+#   1. Check if previous word is a global option; if so, propose arguments.
+#   2. Check if current word is a global option; if so, propose completion.
+#   3. Check for the presence of a main command (qdisc|class|filter|...). If
+#      there is one, first call _tc_direct_complete to see if previous word is
+#      waiting for a particular completion. If so, propose completion and exit.
+#   4. Extract main command and -- if available -- its subcommand
+#      (add|delete|show|...).
+#   5. Propose completion based on main and sub- command in use. Additional
+#      functions may be called for qdiscs, classes or filter options.
+_tc()
+{
+    local cur prev words cword
+    _init_completion || return
+
+    case $prev in
+        -V|-Version)
+            return 0
+            ;;
+        -b|-batch|-cf|-conf)
+            _filedir
+            return 0
+            ;;
+        -force)
+            COMPREPLY=( $( compgen -W '-batch' -- "$cur" ) )
+            return 0
+            ;;
+        -nm|name)
+            [[ -r /etc/iproute2/tc_cls ]] || \
+                COMPREPLY=( $( compgen -W '-conf' -- "$cur" ) )
+            return 0
+            ;;
+        -n|-net|-netns)
+            local nslist=$( ip netns list 2>/dev/null )
+            COMPREPLY+=( $( compgen -W "$nslist" -- "$cur" ) )
+            return 0
+            ;;
+        -tshort)
+            _tc_once_attr '-statistics'
+            COMPREPLY+=( $( compgen -W 'monitor' -- "$cur" ) )
+            return 0
+            ;;
+        -timestamp)
+            _tc_once_attr '-statistics -tshort'
+            COMPREPLY+=( $( compgen -W 'monitor' -- "$cur" ) )
+            return 0
+            ;;
+    esac
+
+    # Search for main commands
+    local subcword cmd subcmd
+    for (( subcword=1; subcword < ${#words[@]}-1; subcword++ )); do
+        [[ ${words[subcword]} == -b?(atch) ]] && return 0
+        [[ -n $cmd ]] && subcmd=${words[subcword]} && break
+        [[ ${words[subcword]} != -* && \
+            ${words[subcword-1]} != -@(n?(et?(ns))|c?(on)f) ]] && \
+            cmd=${words[subcword]}
+    done
+
+    if [[ -z $cmd ]]; then
+        case $cur in
+            -*)
+                local c='-Version -statistics -details -raw -pretty \
+                    -iec -graphe -batch -name -netns -timestamp'
+                [[ $cword -eq 1 ]] && c+=' -force'
+                COMPREPLY=( $( compgen -W "$c" -- "$cur" ) )
+                return 0
+                ;;
+            *)
+                COMPREPLY=( $( compgen -W "help $( tc help 2>&1 | \
+                    command sed \
+                    -e '/OBJECT := /!d' \
+                    -e 's/.*{//' \
+                    -e 's/}.*//' \
+                    -e \ 's/|//g' )" -- "$cur" ) )
+                return 0
+                ;;
+        esac
+    fi
+
+    [[ $subcmd == help ]] && return 0
+
+    # For this set of commands we may create COMPREPLY just by analysing the
+    # previous word, if it expects for a specific list of options or values.
+    if [[ $cmd =~ (qdisc|class|filter|action|exec) ]]; then
+        _tc_direct_complete $prev && return 0
+        if [[ ${words[${#words[@]}-3]} == estimator ]]; then
+            local list=$( _tc_expand_units 'secs' 'msecs' 'usecs' )
+            COMPREPLY+=( $( compgen -W "$list" -- "$cur" ) ) && return 0
+        fi
+    fi
+
+    # Completion depends on main command and subcommand in use.
+    case $cmd in
+        qdisc)
+            case $subcmd in
+                add|change|replace|link|del|delete)
+                    if [[ $(($cword-$subcword)) -eq 1 ]]; then
+                        COMPREPLY=( $( compgen -W 'dev' -- "$cur" ) )
+                        return 0
+                    fi
+                    local qdisc qdwd QDISC_KIND=' choke codel bfifo pfifo \
+                        pfifo_head_drop fq fq_codel gred hhf mqprio multiq \
+                        netem pfifo_fast pie red rr sfb sfq tbf atm cbq drr \
+                        dsmark hfsc htb prio qfq '
+                    for ((qdwd=$subcword; qdwd < ${#words[@]}-1; qdwd++)); do
+                        if [[ $QDISC_KIND =~ ' '${words[qdwd]}' ' ]]; then
+                            qdisc=${words[qdwd]}
+                            _tc_qdisc_options $qdisc && return 0
+                        fi
+                    done
+                    _tc_one_of_list $QDISC_KIND
+                    _tc_one_of_list 'root ingress parent clsact'
+                    _tc_once_attr 'handle estimator stab'
+                    ;;
+                show)
+                    _tc_once_attr 'dev'
+                    _tc_one_of_list 'ingress clsact'
+                    _tc_once_attr '-statistics -details -raw -pretty -iec \
+                        -graph -name'
+                    ;;
+                help)
+                    return 0
+                    ;;
+                *)
+                    [[ $cword -eq $subcword ]] && \
+                        COMPREPLY=( $( compgen -W 'help add delete change \
+                            replace link show' -- "$cur" ) )
+                    ;;
+            esac
+            ;;
+
+        class)
+            case $subcmd in
+                add|change|replace|del|delete)
+                    if [[ $(($cword-$subcword)) -eq 1 ]]; then
+                        COMPREPLY=( $( compgen -W 'dev' -- "$cur" ) )
+                        return 0
+                    fi
+                    local qdisc qdwd QDISC_KIND=' choke codel bfifo pfifo \
+                        pfifo_head_drop fq fq_codel gred hhf mqprio multiq \
+                        netem pfifo_fast pie red rr sfb sfq tbf atm cbq drr \
+                        dsmark hfsc htb prio qfq '
+                    for ((qdwd=$subcword; qdwd < ${#words[@]}-1; qdwd++)); do
+                        if [[ $QDISC_KIND =~ ' '${words[qdwd]}' ' ]]; then
+                            qdisc=${words[qdwd]}
+                            _tc_qdisc_options $qdisc && return 0
+                        fi
+                    done
+                    _tc_one_of_list $QDISC_KIND
+                    _tc_one_of_list 'root parent'
+                    _tc_once_attr 'classid'
+                    ;;
+                show)
+                    _tc_once_attr 'dev'
+                    _tc_one_of_list 'root parent'
+                    _tc_once_attr '-statistics -details -raw -pretty -iec \
+                        -graph -name'
+                    ;;
+                help)
+                    return 0
+                    ;;
+                *)
+                    [[ $cword -eq $subcword ]] && \
+                        COMPREPLY=( $( compgen -W 'help add delete change \
+                            replace show' -- "$cur" ) )
+                    ;;
+            esac
+            ;;
+
+        filter)
+            case $subcmd in
+                add|change|replace|del|delete)
+                    if [[ $(($cword-$subcword)) -eq 1 ]]; then
+                        COMPREPLY=( $( compgen -W 'dev' -- "$cur" ) )
+                        return 0
+                    fi
+                    local filter fltwd FILTER_KIND=' basic bpf cgroup flow \
+                        flower fw route rsvp tcindex u32 '
+                    for ((fltwd=$subcword; fltwd < ${#words[@]}-1; fltwd++));
+                    do
+                        if [[ $FILTER_KIND =~ ' '${words[fltwd]}' ' ]]; then
+                            filter=${words[fltwd]}
+                            _tc_filter_options $filter && return 0
+                        fi
+                    done
+                    _tc_one_of_list $FILTER_KIND
+                    _tc_one_of_list 'root ingress egress parent'
+                    _tc_once_attr 'handle estimator pref protocol'
+                    ;;
+                show)
+                    _tc_once_attr 'dev'
+                    _tc_one_of_list 'root ingress egress parent'
+                    _tc_once_attr '-statistics -details -raw -pretty -iec \
+                        -graph -name'
+                    ;;
+                help)
+                    return 0
+                    ;;
+                *)
+                    [[ $cword -eq $subcword ]] && \
+                        COMPREPLY=( $( compgen -W 'help add delete change \
+                            replace show' -- "$cur" ) )
+                    ;;
+            esac
+            ;;
+
+        action)
+            case $subcmd in
+                add|change|replace)
+                    local action acwd ACTION_KIND=' gact mirred bpf '
+                    for ((acwd=$subcword; acwd < ${#words[@]}-1; acwd++)); do
+                        if [[ $ACTION_KIND =~ ' '${words[acwd]}' ' ]]; then
+                            action=${words[acwd]}
+                            _tc_action_options $action && return 0
+                        fi
+                    done
+                    _tc_one_of_list $ACTION_KIND
+                    ;;
+                get|del|delete)
+                    _tc_once_attr 'index'
+                    ;;
+                lst|list|flush|show)
+                    _tc_one_of_list $ACTION_KIND
+                    ;;
+                *)
+                    [[ $cword -eq $subcword ]] && \
+                        COMPREPLY=( $( compgen -W 'help add delete change \
+                            replace show list flush action' -- "$cur" ) )
+                    ;;
+            esac
+            ;;
+
+        monitor)
+            COMPREPLY=( $( compgen -W 'help' -- "$cur" ) )
+            ;;
+
+        exec)
+            case $subcmd in
+                bpf)
+                    local excmd exwd EXEC_KIND=' import debug graft '
+                    for ((exwd=$subcword; exwd < ${#words[@]}-1; exwd++)); do
+                        if [[ $EXEC_KIND =~ ' '${words[exwd]}' ' ]]; then
+                            excmd=${words[exwd]}
+                            _tc_exec_options $excmd && return 0
+                        fi
+                    done
+                    _tc_one_of_list $EXEC_KIND
+                    ;;
+                *)
+                    [[ $cword -eq $subcword ]] && \
+                        COMPREPLY=( $( compgen -W 'bpf' -- "$cur" ) )
+                    ;;
+            esac
+            ;;
+    esac
+} &&
+complete -F _tc tc
+
+# ex: ts=4 sw=4 et filetype=sh
-- 
2.1.4
