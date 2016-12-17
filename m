From: Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Potential issues (security and otherwise) with the current cgroup-bpf API
Date: Sat, 17 Dec 2016 10:18:44 -0800
Message-ID: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a1143a744bc13ce0543deb8e4
Cc: Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>,
        Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, David Ahern <dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--001a1143a744bc13ce0543deb8e4
Content-Type: text/plain; charset=UTF-8

Hi all-

I apologize for being rather late with this.  I didn't realize that
cgroup-bpf was going to be submitted for Linux 4.10, and I didn't see
it on the linux-api list, so I missed the discussion.

I think that the inet ingress, egress etc filters are a neat feature,
but I think the API has some issues that will bite us down the road
if it becomes stable in its current form.

Most of the problems I see are summarized in this transcript:

# mkdir cg2
# mount -t cgroup2 none cg2
# mkdir cg2/nosockets
# strace cgrp_socket_rule cg2/nosockets/ 0
...
open("cg2/nosockets/", O_RDONLY|O_DIRECTORY) = 3

^^^^ You can modify a cgroup after opening it O_RDONLY?

bpf(BPF_PROG_LOAD, {prog_type=0x9 /* BPF_PROG_TYPE_??? */, insn_cnt=2,
insns=0x7fffe3568c10, license="GPL", log_level=1, log_size=262144,
log_buf=0x6020c0, kern_version=0}, 48) = 4

^^^^ This is fine.  The bpf() syscall manipulates bpf objects.

bpf(0x8 /* BPF_??? */, 0x7fffe3568bf0, 48) = 0

^^^^ This is not so good:
^^^^
^^^^ a) The bpf() syscall is supposed to manipulate bpf objects.  This
^^^^    is manipulating a cgroup.  There's no reason that a socket creation
^^^^    filter couldn't be written in a different language (new iptables
^^^^    table?  Simple list of address families?), but if that happened,
^^^^    then using bpf() to install it would be entirely nonsensical.
^^^^
^^^^ b) This is starting to be an excessively ugly multiplexer.  Among
^^^^    other things, it's very unfriendly to seccomp.

# echo $$ >cg2/nosockets/cgroup.procs
# ping 127.0.0.1
ping: socket: Operation not permitted
# ls cg2/nosockets/
cgroup.controllers  cgroup.events  cgroup.procs  cgroup.subtree_control
# cat cg2/nosockets/cgroup.controllers

^^^^ Something in cgroupfs should give an indication that this cgroup
^^^^ filters socket creation, but there's nothing there.  You should also
^^^^ be able to turn the filter off from cgroupfs.

# mkdir cg2/nosockets/sockets
# /home/luto/apps/linux/samples/bpf/cgrp_socket_rule cg2/nosockets/sockets/ 1

^^^^ This succeeded, which means that, if this feature is enabled in 4.10,
^^^^ then we're stuck with its semantics.  If it returned -EINVAL instead,
^^^^ there would be a chance to refine it.

# echo $$ >cg2/nosockets/sockets/cgroup.procs
# ping 127.0.0.1
PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.029 ms
^C
--- 127.0.0.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.029/0.029/0.029/0.000 ms

^^^^ Bash was inside a cgroup that disallowed socket creation, but socket
^^^^ creation wasn't disallowed.  This means that the obvious use of socket
^^^^ creation filters in nestable constainers fails insecurely.


There's also a subtle but nasty potential security problem here.
In 4.9 and before, cgroups has only one real effect in the kernel:
resource control. A process in a malicious cgroup could be DoSed,
but that was about the extent of the damage that a malicious cgroup
could do.

In 4.10 with With CONFIG_CGROUP_BPF=y, a cgroup can have bpf
programs attached that can do things if various events occur. (Right
now, this means socket operations, but there are plans in the works
to do this for LSM hooks too.) These bpf programs can say yes or no,
but they can also read out various data (including socket payloads!)
and save them away where an attacker can find them. This sounds a
lot like seccomp with a narrower scope but a much stronger ability to
exfiltrate private information.

Unfortunately, while seccomp is very, very careful to prevent
injection of a privileged victim into a malicious sandbox, the
CGROUP_BPF mechanism appears to have no real security model. There
is nothing to prevent a program that's in a malicious cgroup from
running a setuid binary, and there is nothing to prevent a program
that has the ability to move itself or another program into a
malicious cgroup from doing so and then, if needed for exploitation,
exec a setuid binary.

This isn't much of a problem yet because you currently need
CAP_NET_ADMIN to create a malicious sandbox in the first place.  I'm
sure that, in the near future, someone will want to make this stuff
work in containers with delegated cgroup hierarchies, and then there
may be a real problem here.


I've included a few security people on this thread.  The current API
looks abusable, and it would be nice to find all the holes before
4.10 comes out.


(The cgrp_socket_rule source is attached.  You can build it by sticking it
 in samples/bpf and doing:

 $ make headers_install
 $ cd samples/bpf
 $ gcc -o cgrp_socket_rule cgrp_socket_rule.c libbpf.c -I../../usr/include
)

--Andy

--001a1143a744bc13ce0543deb8e4
Content-Type: text/x-csrc; charset=US-ASCII; name="cgrp_socket_rule.c"
Content-Disposition: attachment; filename="cgrp_socket_rule.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iwtjntse0

LyogZUJQRiBleGFtcGxlIHByb2dyYW06CiAqCiAqIC0gTG9hZHMgZUJQRiBwcm9ncmFtCiAqCiAq
ICAgVGhlIGVCUEYgcHJvZ3JhbSBzZXRzIHRoZSBza19ib3VuZF9kZXZfaWYgaW5kZXggaW4gbmV3
IEFGX0lORVR7Nn0KICogICBzb2NrZXRzIG9wZW5lZCBieSBwcm9jZXNzZXMgaW4gdGhlIGNncm91
cC4KICoKICogLSBBdHRhY2hlcyB0aGUgbmV3IHByb2dyYW0gdG8gYSBjZ3JvdXAgdXNpbmcgQlBG
X1BST0dfQVRUQUNICiAqLwoKI2RlZmluZSBfR05VX1NPVVJDRQoKI2luY2x1ZGUgPHN0ZGlvLmg+
CiNpbmNsdWRlIDxzdGRsaWIuaD4KI2luY2x1ZGUgPHN0ZGRlZi5oPgojaW5jbHVkZSA8c3RyaW5n
Lmg+CiNpbmNsdWRlIDx1bmlzdGQuaD4KI2luY2x1ZGUgPGFzc2VydC5oPgojaW5jbHVkZSA8ZXJy
bm8uaD4KI2luY2x1ZGUgPGZjbnRsLmg+CiNpbmNsdWRlIDxuZXQvaWYuaD4KI2luY2x1ZGUgPGxp
bnV4L2JwZi5oPgoKI2luY2x1ZGUgImxpYmJwZi5oIgoKc3RhdGljIGludCBwcm9nX2xvYWQoaW50
IHZhbHVlKQp7CglzdHJ1Y3QgYnBmX2luc24gcHJvZ1tdID0gewoJCUJQRl9NT1Y2NF9JTU0oQlBG
X1JFR18wLCB2YWx1ZSksIC8qIHIwID0gdmVyZGljdCAqLwoJCUJQRl9FWElUX0lOU04oKSwKCX07
CgoJcmV0dXJuIGJwZl9wcm9nX2xvYWQoQlBGX1BST0dfVFlQRV9DR1JPVVBfU09DSywgcHJvZywg
c2l6ZW9mKHByb2cpLAoJCQkgICAgICJHUEwiLCAwKTsKfQoKc3RhdGljIGludCB1c2FnZShjb25z
dCBjaGFyICphcmd2MCkKewoJcHJpbnRmKCJVc2FnZTogJXMgY2ctcGF0aCB2YWx1ZVxuIiwgYXJn
djApOwoJcmV0dXJuIEVYSVRfRkFJTFVSRTsKfQoKaW50IG1haW4oaW50IGFyZ2MsIGNoYXIgKiph
cmd2KQp7CglpbnQgY2dfZmQsIHByb2dfZmQsIHZhbHVlLCByZXQ7CgoJaWYgKGFyZ2MgPCAyKQoJ
CXJldHVybiB1c2FnZShhcmd2WzBdKTsKCgljZ19mZCA9IG9wZW4oYXJndlsxXSwgT19ESVJFQ1RP
UlkgfCBPX1JET05MWSk7CglpZiAoY2dfZmQgPCAwKSB7CgkJcHJpbnRmKCJGYWlsZWQgdG8gb3Bl
biBjZ3JvdXAgcGF0aDogJyVzJ1xuIiwgc3RyZXJyb3IoZXJybm8pKTsKCQlyZXR1cm4gRVhJVF9G
QUlMVVJFOwoJfQoKCXZhbHVlID0gYXRvaShhcmd2WzJdKTsKCglwcm9nX2ZkID0gcHJvZ19sb2Fk
KHZhbHVlKTsKCS8qIHByaW50ZigiT3V0cHV0IGZyb20ga2VybmVsIHZlcmlmaWVyOlxuJXNcbi0t
LS0tLS1cbiIsIGJwZl9sb2dfYnVmKTsgKi8KCglpZiAocHJvZ19mZCA8IDApIHsKCQlwcmludGYo
IkZhaWxlZCB0byBsb2FkIHByb2c6ICclcydcbiIsIHN0cmVycm9yKGVycm5vKSk7CgkJcmV0dXJu
IEVYSVRfRkFJTFVSRTsKCX0KCglyZXQgPSBicGZfcHJvZ19hdHRhY2gocHJvZ19mZCwgY2dfZmQs
IEJQRl9DR1JPVVBfSU5FVF9TT0NLX0NSRUFURSk7CglpZiAocmV0IDwgMCkgewoJCXByaW50Zigi
RmFpbGVkIHRvIGF0dGFjaCBwcm9nIHRvIGNncm91cDogJyVzJ1xuIiwKCQkgICAgICAgc3RyZXJy
b3IoZXJybm8pKTsKCQlyZXR1cm4gRVhJVF9GQUlMVVJFOwoJfQoKCXJldHVybiBFWElUX1NVQ0NF
U1M7Cn0K
--001a1143a744bc13ce0543deb8e4--
