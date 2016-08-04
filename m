From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC 0/4] RFC: Add Checmate, BPF-driven minor LSM
Date: Thu, 04 Aug 2016 11:45:08 +0200
Message-ID: <57A30EA4.8010400@iogearbox.net>
References: <20160804071116.GA19098@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: Sargun Dhillon <sargun@sargun.me>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160804071116.GA19098@ircssh.c.rugged-nimbus-611.internal>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sargun,

On 08/04/2016 09:11 AM, Sargun Dhillon wrote:
[...]
> [It's a] minor LSM. My particular use case is one in which containers are being
> dynamically deployed to machines by internal developers in a different group.
[...]
> For many of these containers, the security policies can be fairly nuanced. One
> particular one to take into account is network security. Often times,
> administrators want to prevent ingress, and egress connectivity except from a
> few select IPs. Egress filtering can be managed using net_cls, but without
> modifying running software, it's non-trivial to attach a filter to all sockets
> being created within a container. The inet_conn_request, socket_recvmsg,
> socket_sock_rcv_skb hooks make this trivial to implement.

I'm not too familiar with LSMs, but afaik, when you install such policies they
are effectively global, right? How would you install/manage such policies per
container?

On a quick glance, this would then be the job of the BPF proglet from the global
hook, no? If yes, then the BPF contexts the BPF prog works with seem rather quite
limited ...

+struct checmate_file_open_ctx {
+	struct file *file;
+	const struct cred *cred;
+};
+
+struct checmate_task_create_ctx {
+	unsigned long clone_flags;
+};
+
+struct checmate_task_free_ctx {
+	struct task_struct *task;
+};
+
+struct checmate_socket_connect_ctx {
+	struct socket *sock;
+	struct sockaddr *address;
+	int addrlen;
+};

... or are you using bpf_probe_read() in some way to walk 'current' to retrieve
a namespace from there somehow? Like via nsproxy? But how you make sense of this
for defining a per container policy?

Do you see a way where we don't need to define so many different ctx each time?

My other concern from a security PoV is that when using things like bpf_probe_read()
we're dependent on kernel structs and there's a risk that when people migrate such
policies that expectations break due to underlying structs changed. I see you've
addressed that in patch 4 to place a small stone in the way, yeah kinda works. It's
mostly a reminder that this is not stable ABI.

Thanks,
Daniel
