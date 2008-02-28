From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 0/2] Fix /proc/net in presence of net namespaces
Date: Thu, 28 Feb 2008 18:46:11 +0300
Message-ID: <47C6D743.1050802@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:37739 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758583AbYB1PrG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 10:47:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current /proc/net is done with so called "shadows", but current
implementation is broken and has little chances to get fixed.

The problem is that dentries subtree of /proc/net directory has
fancy revalidation rules to make processes living in different
net namespaces see different entries in /proc/net subtree, but
currently, tasks see in the /proc/net subdir the contents of any
other namespace, depending on who opened the file first.

The proposed fix is to turn /proc/net into a symlink, which behaves
similar to /proc/self link - it points to .netns/<id> directory 
where the <id> is the id of net namespace, current task lives in.

# ls -l /proc/net
lrwxrwxrwx  1 root root 8 Feb 28 18:38 /proc/net -> .netns/0

The /proc/.netns dir contains subtrees for all the namespaces in 
the system:

# ls -l /proc/.netns/
total 0
dr-xr-xr-x  5 root root 0 Feb 28 18:39 0
dr-xr-xr-x  3 root root 0 Feb 28 18:39 1

To provide some security each /proc/.netns/<id> directory allows
access to tasks that live in the owning namespace only (with the
exception, that init_net tasks can see everything).

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
