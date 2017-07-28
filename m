From: Rolf Neugebauer <rolf.neugebauer@docker.com>
Subject: Long stalls creating a new netns after a netns with a SMB client exits
Date: Fri, 28 Jul 2017 17:47:02 +0100
Message-ID: <CA+pO-2cm7bz861KvPMpugP8rVwf6rU8QYrVq7PVO-ZXx2kh1fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Rolf Neugebauer <rolf.neugebauer@docker.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:35913 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752442AbdG1QrE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 12:47:04 -0400
Received: by mail-pg0-f52.google.com with SMTP id 125so113316941pgi.3
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 09:47:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

several docker users reported long stalls when they used containers
with network filesystem mounts. For example, this was reported here:
https://github.com/moby/moby/issues/5618#issuecomment-314515980.
Another user, Pierre Carru (@piec on GH), then managed to create a
simpler reproduction here: https://github.com/piec/docker-samba-loop
which I analysed initially here:
https://github.com/moby/moby/issues/5618#issuecomment-318432218

I managed to condense a repro down to a simple script below, which
does not rely on docker.
- Configure and start a SMB server on the host
- Create a veth pair and configure one peer in the root namespace
- Create a network namespace and move and configure the other veth peer there
- Execute a (mount.cifs; ls; unmount) inside the network namespace
(and in its own mount namespace, though the mount namespace is not
strictly required)
- Direclty after the 'unmount', delete the network namespace and try
to create a new network namespace

Creating the new namespace is stalling for around 200 seconds and
there 20 odd messages on the console, like:

[   67.372603] unregister_netdevice: waiting for lo to become free.
Usage count = 1

Adding a 'sleep 1' before deleting the original network namespace
"solves" the issue, but that doesn't sound like a good fix. Not using
unmount also does not help (understandable).

While the creation of the new namespace is stalled, I used 'sysrq' a
few times to dump the work queues. There is an example below. Also,
the hung task detection kicks in after 120 seconds (also below)

I can readily reproduce this on 4.9.39, 4.11.12 and another user
repro-ed it on 4.12.3. It seems to happen every time. At least one
user reported issues with NFS mounts as well, but we were not able to
reproduce it. It's not clear to me if this is directly related to
'mount.cifs' or if that just happens to reliably repro it.

It would be great if someone more familiar with the code could take a
look. I'm happy to provide additional info (perf traces etc) or test
patches if needed.

Thanks
Rolf


Work queue dump:
----------------
[   67.372603] unregister_netdevice: waiting for lo to become free.
Usage count = 1
[   76.821394] sysrq: SysRq : Show Blocked State
[   76.821820]   task                        PC stack   pid father
[   76.822394] kworker/u2:0    D    0     6      2 0x00000000
[   76.822896] Workqueue: netns cleanup_net
[   76.823216]  0000000000018980 0000000000000000 ffff99797a80f080
ffffffff89c10500
[   76.824007]  ffff99797c9980c0 ffff99797cc18980 ffffffff897cfc83
0000000000000002
[   76.824809]  ffff99797c9980c0 ffffb3580002fd00 ffffb3580002fd28
0000000000000001
[   76.825551] Call Trace:
[   76.826001]  [<ffffffff897cfc83>] ? __schedule+0x364/0x465
[   76.826468]  [<ffffffff897cfe02>] ? schedule+0x7e/0x87
[   76.826913]  [<ffffffff897d1b0a>] ? schedule_timeout+0xc1/0x101
[   76.827431]  [<ffffffff89127ba6>] ? del_timer_sync+0x42/0x42
[   76.827875]  [<ffffffff89127f62>] ? msleep+0x1a/0x1d
[   76.828328]  [<ffffffff89127f62>] ? msleep+0x1a/0x1d
[   76.828783]  [<ffffffff8963ba0b>] ? netdev_run_todo+0x158/0x296
[   76.829311]  [<ffffffff89636cf4>] ? default_device_exit_batch+0x138/0x158
[   76.829907]  [<ffffffff8910ea06>] ? __wake_up_sync+0x9/0x9
[   76.830411]  [<ffffffff896308e1>] ? cleanup_net+0x1a1/0x252
[   76.830973]  [<ffffffff890f2adb>] ? process_one_work+0x185/0x287
[   76.832052]  [<ffffffff890f30a5>] ? worker_thread+0x1d8/0x2ab
[   76.833063]  [<ffffffff890f2ecd>] ? rescuer_thread+0x2c4/0x2c4
[   76.833769]  [<ffffffff890f739c>] ? kthread+0xb4/0xbc
[   76.834350]  [<ffffffff890f72e8>] ? init_completion+0x1d/0x1d
[   76.834859]  [<ffffffff897d2a55>] ? ret_from_fork+0x25/0x30
[   76.835644] ip              D    0   656    653 0x00000000
[   76.836260]  0000000000018980 0000000000000000 ffff99796ca68840
ffffffff89c10500
[   76.836960]  ffff99796cb9ce80 ffff99797cc18980 ffffffff897cfc83
0000000000000002
[   76.837665]  ffff99796cb9ce80 ffffb35800433e60 ffffffff89d006e4
ffff99796cb9ce80
[   76.838369] Call Trace:
[   76.838604]  [<ffffffff897cfc83>] ? __schedule+0x364/0x465
[   76.839126]  [<ffffffff897cfe02>] ? schedule+0x7e/0x87
[   76.839525]  [<ffffffff897cffcd>] ? schedule_preempt_disabled+0xa/0xb
[   76.840139]  [<ffffffff897d10f1>] ? __mutex_lock_slowpath+0xb6/0x13b
[   76.840751]  [<ffffffff897d1191>] ? mutex_lock+0x1b/0x2a
[   76.841234]  [<ffffffff897d1191>] ? mutex_lock+0x1b/0x2a
[   76.841829]  [<ffffffff89630a36>] ? copy_net_ns+0xa4/0x12c
[   76.842335]  [<ffffffff890f848d>] ? create_new_namespaces+0x125/0x191
[   76.842859]  [<ffffffff890f8675>] ? unshare_nsproxy_namespaces+0x87/0xa4
[   76.843788]  [<ffffffff890dd418>] ? SyS_unshare+0x17b/0x306
[   76.844263]  [<ffffffff897d27f7>] ? entry_SYSCALL_64_fastpath+0x1a/0xa9
[   77.648626] unregister_netdevice: waiting for lo to become free.
Usage count = 1


Hung task detection
-------------------
[  241.612198] unregister_netdevice: waiting for lo to become free.
Usage count = 1
[  243.955712] INFO: task ip:656 blocked for more than 120 seconds.
[  243.956292]       Not tainted 4.9.39-linuxkit #1
[  243.956703] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[  243.957394] ip              D    0   656    653 0x00000000
[  243.957963]  0000000000018980 0000000000000000 ffff99796ca68840
ffffffff89c10500
[  243.958701]  ffff99796cb9ce80 ffff99797cc18980 ffffffff897cfc83
0000000000000002
[  243.959438]  ffff99796cb9ce80 ffffb35800433e60 ffffffff89d006e4
ffff99796cb9ce80
[  243.960175] Call Trace:
[  243.960482]  [<ffffffff897cfc83>] ? __schedule+0x364/0x465
[  243.961063]  [<ffffffff897cfe02>] ? schedule+0x7e/0x87
[  243.961538]  [<ffffffff897cffcd>] ? schedule_preempt_disabled+0xa/0xb
[  243.962052]  [<ffffffff897d10f1>] ? __mutex_lock_slowpath+0xb6/0x13b
[  243.962642]  [<ffffffff897d1191>] ? mutex_lock+0x1b/0x2a
[  243.963156]  [<ffffffff897d1191>] ? mutex_lock+0x1b/0x2a
[  243.963649]  [<ffffffff89630a36>] ? copy_net_ns+0xa4/0x12c
[  243.964166]  [<ffffffff890f848d>] ? create_new_namespaces+0x125/0x191
[  243.964757]  [<ffffffff890f8675>] ? unshare_nsproxy_namespaces+0x87/0xa4
[  243.965381]  [<ffffffff890dd418>] ? SyS_unshare+0x17b/0x306
[  243.965898]  [<ffffffff897d27f7>] ? entry_SYSCALL_64_fastpath+0x1a/0xa9
[  251.877100] unregister_netdevice: waiting for lo to become free.
Usage count = 1
[  262.139630] unregister_netdevice: waiting for lo to become free.
Usage count = 1

Script to repro:
----------------
apk add --no-cache iproute2 samba samba-common-tools cifs-utils
# For debian/ubuntu
# apt-get install -y samba cifs-utils

# SMB server setup
cat <<EOF > /etc/samba/smb.conf
[global]
    workgroup = WORKGROUP
    netbios name = FOO
    passdb backend = tdbsam
    security = user
    guest account = nobody
    strict locking = no
    min protocol = SMB2
[public]
    path = /share
    browsable = yes
    read only = no
    guest ok = yes
    browseable = yes
    create mask = 777
EOF
adduser -D -G nobody nobody && smbpasswd -a -n nobody
mkdir /share && chmod ugo+rwx /share && touch /share/foo
chown -R nobody.nobody /share
# Start SMB server and sleep for it to serve
smbd -D

# Bring up a veth pair
ip link add hdev type veth peer name nsdev
ip addr add 10.0.0.1/24 dev hdev
ip link set hdev up

# Create namespace and configure veth peer
ip netns add client-ns
ip link set nsdev netns client-ns
ip netns exec client-ns ip addr add 10.0.0.2/24 dev nsdev
ip netns exec client-ns ip link set lo up
ip netns exec client-ns ip link set nsdev up
sleep 1 # Wait for device to be up

# Execute (mount, ls, unmount) in the network namespace and a new
mount namespace
ip netns exec client-ns unshare --mount \
    /bin/sh -c 'mount.cifs //10.0.0.1/public /mnt -o vers=3.0,guest;
ls /mnt; umount /mnt'

# Delete the client network namespace.
ip netns del client-ns

# create a new namespace. This stalls
ip netns add client-ns2
