From: Kieran Mansley <kmansley@solarflare.com>
Subject: [PATCH 2/4] [Net] Support Xen accelerated network
	plugin modules
Date: Fri, 18 May 2007 14:16:28 +0100
Message-ID: <1179494188.14376.9.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Bh5lzEDOcA83XJQTIWEI"
Cc: muli@il.ibm.com, netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: xen-devel@lists.xensource.com
Return-path: <xen-devel-bounces@lists.xensource.com>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org


--=-Bh5lzEDOcA83XJQTIWEI
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Add accel option to vif xend config to allow users to specify which
interfaces should be accelerated using which plugin modules.

diff -r 194f5b88d257 tools/python/xen/xend/server/netif.py
--- a/tools/python/xen/xend/server/netif.py Tue Apr 17 09:04:51 2007
+0100
+++ b/tools/python/xen/xend/server/netif.py Tue Apr 17 09:06:58 2007
+0100
@@ -107,6 +107,7 @@ class NetifController(DevController):
         uuid    = config.get('uuid')
         ipaddr  = config.get('ip')
         model   = config.get('model')
+        accel   = config.get('accel')

         if not typ:
             typ = xoptions.netback_type
@@ -131,6 +132,8 @@ class NetifController(DevController):
             back['uuid'] = uuid
         if model:
             back['model'] = model
+        if accel:
+            back['accel'] = accel

         config_path = "device/%s/%d/" % (self.deviceClass, devid)
         for x in back:
@@ -157,10 +160,10 @@ class NetifController(DevController):
         config_path = "device/%s/%d/" % (self.deviceClass, devid)
         devinfo = ()
         for x in ( 'script', 'ip', 'bridge', 'mac',
-                   'type', 'vifname', 'rate', 'uuid', 'model' ):
+                   'type', 'vifname', 'rate', 'uuid', 'model',
'accel'):
             y = self.vm._readVm(config_path + x)
             devinfo += (y,)
-        (script, ip, bridge, mac, typ, vifname, rate, uuid, model) =
devinfo
+        (script, ip, bridge, mac, typ, vifname, rate, uuid, model,
accel) = devinfo

         if script:
             result['script'] = script
@@ -180,5 +183,7 @@ class NetifController(DevController):
             result['uuid'] = uuid
         if model:
             result['model'] = model
+        if accel:
+            result['accel'] = accel
             
         return result
diff -r 194f5b88d257 tools/python/xen/xm/create.py
--- a/tools/python/xen/xm/create.py Tue Apr 17 09:04:51 2007 +0100
+++ b/tools/python/xen/xm/create.py Tue Apr 17 09:04:54 2007 +0100
@@ -710,7 +710,7 @@ def configure_vifs(config_devs, vals):

         def f(k):
             if k not in ['backend', 'bridge', 'ip', 'mac', 'script',
'type',
-                         'vifname', 'rate', 'model']:
+                         'vifname', 'rate', 'model', 'accel']:
                 err('Invalid vif option: ' + k)

             config_vif.append([k, d[k]])


--=-Bh5lzEDOcA83XJQTIWEI
Content-Disposition: attachment; filename=accel_vif_xend
Content-Type: text/plain; name=accel_vif_xend; charset=UTF-8
Content-Transfer-Encoding: 7bit

Add accel option to vif xend config

diff -r 194f5b88d257 tools/python/xen/xend/server/netif.py
--- a/tools/python/xen/xend/server/netif.py	Tue Apr 17 09:04:51 2007 +0100
+++ b/tools/python/xen/xend/server/netif.py	Tue Apr 17 09:06:58 2007 +0100
@@ -107,6 +107,7 @@ class NetifController(DevController):
         uuid    = config.get('uuid')
         ipaddr  = config.get('ip')
         model   = config.get('model')
+        accel   = config.get('accel')
 
         if not typ:
             typ = xoptions.netback_type
@@ -131,6 +132,8 @@ class NetifController(DevController):
             back['uuid'] = uuid
         if model:
             back['model'] = model
+        if accel:
+            back['accel'] = accel
 
         config_path = "device/%s/%d/" % (self.deviceClass, devid)
         for x in back:
@@ -157,10 +160,10 @@ class NetifController(DevController):
         config_path = "device/%s/%d/" % (self.deviceClass, devid)
         devinfo = ()
         for x in ( 'script', 'ip', 'bridge', 'mac',
-                   'type', 'vifname', 'rate', 'uuid', 'model' ):
+                   'type', 'vifname', 'rate', 'uuid', 'model', 'accel'):
             y = self.vm._readVm(config_path + x)
             devinfo += (y,)
-        (script, ip, bridge, mac, typ, vifname, rate, uuid, model) = devinfo
+        (script, ip, bridge, mac, typ, vifname, rate, uuid, model, accel) = devinfo
 
         if script:
             result['script'] = script
@@ -180,5 +183,7 @@ class NetifController(DevController):
             result['uuid'] = uuid
         if model:
             result['model'] = model
+        if accel:
+            result['accel'] = accel
             
         return result
diff -r 194f5b88d257 tools/python/xen/xm/create.py
--- a/tools/python/xen/xm/create.py	Tue Apr 17 09:04:51 2007 +0100
+++ b/tools/python/xen/xm/create.py	Tue Apr 17 09:04:54 2007 +0100
@@ -710,7 +710,7 @@ def configure_vifs(config_devs, vals):
 
         def f(k):
             if k not in ['backend', 'bridge', 'ip', 'mac', 'script', 'type',
-                         'vifname', 'rate', 'model']:
+                         'vifname', 'rate', 'model', 'accel']:
                 err('Invalid vif option: ' + k)
 
             config_vif.append([k, d[k]])

--=-Bh5lzEDOcA83XJQTIWEI
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Xen-devel mailing list
Xen-devel@lists.xensource.com
http://lists.xensource.com/xen-devel

--=-Bh5lzEDOcA83XJQTIWEI--
